# frozen_string_literal: true

class SimulatorController < ApplicationController
  include SimulatorHelper
  include ActionView::Helpers::SanitizeHelper

  before_action :authenticate_user!, only: %i[create update edit]
  before_action :set_project, only: %i[show embed get_data]
  before_action :set_user_project, only: %i[update edit]
  before_action :check_view_access, only: %i[show embed get_data]
  before_action :check_edit_access, only: %i[edit update]
  skip_before_action :verify_authenticity_token, only: %i[get_data create update verilog_cv]
  after_action :allow_iframe, only: %i[embed]
  after_action :allow_iframe_lti, only: %i[show], constraints: lambda {
    Flipper.enabled?(:lms_integration, current_user)
  }

  def self.policy_class
    ProjectPolicy
  end

  def show
    @logix_project_id = params[:id]
    @external_embed = false
    if Flipper.enabled?(:vuesim, current_user)
      render "embed_vue", layout: false
    else
      render "embed"
    end
  end

  def new
    @logix_project_id = 0
    @projectName = ""
    if Flipper.enabled?(:vuesim, current_user)
      render "edit_vue", layout: false
    else
      render "edit"
    end
  end

  def edit
    @logix_project_id = params[:id]
    @projectName = @project.name
    if Flipper.enabled?(:vuesim, current_user)
      render :edit_vue, layout: false
    else
      render :edit
    end
  end

  def embed
    authorize @project
    @logix_project_id = params[:id]
    @project = Project.friendly.find(params[:id])
    @author = @project.author_id
    @external_embed = true
    if Flipper.enabled?(:vuesim, current_user)
      render :embed_vue, layout: false
    else
      render :embed
    end
  end

  def get_data
    render json: ProjectDatum.find_by(project: @project)&.data
  end

  def create
    @project = Project.new
    @project.build_project_datum.data = sanitize_data(@project, params[:data])
    @project.name = sanitize(params[:name])
    @project.author = current_user
    # ActiveStorage
    io_image_file = parse_image_data_url(params[:image])
    attach_circuit_preview(io_image_file)
    # CarrierWave
    image_file = return_image_file(params[:image])
    @project.image_preview = image_file
    image_file.close
    @project.save!

    # render plain: simulator_path(@project)
    # render plain: user_project_url(current_user,@project)
    redirect_to edit_user_project_url(current_user, @project)
  end

  def update
    @project.build_project_datum unless ProjectDatum.exists?(project_id: @project.id)
    @project.project_datum.data = sanitize_data(@project, params[:data])
    # ActiveStorage
    @project.circuit_preview.purge if @project.circuit_preview.attached?
    io_image_file = parse_image_data_url(params[:image])
    attach_circuit_preview(io_image_file)
    # CarrierWave
    image_file = return_image_file(params[:image])
    @project.image_preview = image_file
    image_file.close
    File.delete(image_file) if check_to_delete(params[:image])
    @project.name = sanitize(params[:name])
    @project.save
    @project.project_datum.save
    render plain: "success"
  end

  def view_issue_circuit_data
    unless current_user&.admin?
      render plain: "Only admins can view issue circuit data", status: :unauthorized
      return
    end

    issue_circuit_data = IssueCircuitDatum.find(params[:id])
    render plain: issue_circuit_data.data
  end

  def post_issue
    url = ENV.fetch("SLACK_ISSUE_HOOK_URL", nil)

    # Post the issue circuit data
    issue_circuit_data = IssueCircuitDatum.new
    issue_circuit_data.data = params[:circuit_data]
    issue_circuit_data.save!

    issue_circuit_data_id = issue_circuit_data.id

    # Send it over to slack hook
    circuit_data_url = "#{request.base_url}/simulator/issue_circuit_data/#{issue_circuit_data_id}"
    text = "#{params[:text]}\nCircuit Data: #{circuit_data_url}"
    HTTP.post(url, json: { text: text }) if Flipper.enabled?(:slack_issue_notification)
    head :ok, content_type: "text/html"
  end

  MAX_CODE_SIZE = 10_000 # 10KB limit

  def verilog_cv
    if params[:code].to_s.bytesize > MAX_CODE_SIZE
      render json: { message: "Code too large (max #{MAX_CODE_SIZE} bytes)" }, status: :payload_too_large
      return
    end

    if Flipper.enabled?(:yosys_local_gem, current_user)
      compile_with_local_gem
    else
      compile_with_external_api
    end
  end

  def allow_iframe_lti
    return unless session[:is_lti]

    response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM #{session[:lms_domain]}"
  end

  private

    def allow_iframe
      response.headers.except! "X-Frame-Options"
    end

    # HTTP client with reasonable timeouts to prevent hanging
    def http_client
      HTTP.timeout(connect: 5, write: 10, read: 30)
    end

    def compile_with_local_gem
      code = params[:code].to_s
      result = Yosys2Digitaljs::Runner.compile(code)
      render json: result
    rescue Yosys2Digitaljs::SyntaxError => e
      render json: { message: "Syntax Error: #{e.message}" }, status: :unprocessable_entity
    rescue Yosys2Digitaljs::Runner::TimeoutError => e
      render json: { message: e.message }, status: :service_unavailable
    rescue Yosys2Digitaljs::Error => e
      render json: { message: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error("[Yosys Compilation Error] #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}")
      render json: { message: "Compilation failed" }, status: :internal_server_error
    end

    def compile_with_external_api
      yosys_url = "#{ENV.fetch('YOSYS_PATH', 'http://127.0.0.1:3040')}/getJSON"
      response = http_client.post(yosys_url, json: { code: params[:code].to_s })
      render json: JSON.parse(response.to_s), status: response.code
    rescue HTTP::TimeoutError
      render json: { message: "Yosys service timed out" }, status: :gateway_timeout
    rescue HTTP::Error => e
      Rails.logger.error("[Yosys External API Error] #{e.class}: #{e.message}")
      render json: { message: "External API unavailable" }, status: :service_unavailable
    rescue JSON::ParserError
      render json: { message: "Invalid response from Yosys API" }, status: :internal_server_error
    end

    def set_project
      @project = Project.friendly.find(params[:id])
    end

    def set_user_project
      @project = Project.friendly.find(params[:id])
      authorize @project, :edit_access?
    end

    def check_edit_access
      authorize @project, :edit_access?
    end

    def check_view_access
      authorize @project, :view_access?
    end

    def attach_circuit_preview(image_file)
      return unless image_file

      @project.circuit_preview.attach(
        io: image_file,
        filename: "preview_#{Time.zone.now.to_f.to_s.sub('.', '')}.jpeg",
        content_type: "img/jpeg"
      )
    end
end
