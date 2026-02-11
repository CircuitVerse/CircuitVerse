# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
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

  # rubocop:disable Metrics/MethodLength
  def verilog_cv
    if params[:code].blank?
      render json: { error: "Code parameter is required" }, status: :bad_request
      return
    end

    url = "#{ENV.fetch('YOSYS_PATH', 'http://127.0.0.1:3040')}/getJSON"
    begin
      response = HTTP.timeout(connect: 30, read: 30, write: 30).post(url, json: { code: params[:code] })
      if response.status.success?
        render json: response.body.to_s, status: response.code
      else
        Rails.logger.error "Yosys service returned error status: #{response.code}"
        render json: { error: "Verilog synthesis service returned an error. Please try again later." },
               status: :service_unavailable
      end
    rescue HTTP::TimeoutError, HTTP::ConnectionError => e
      Rails.logger.error "Verilog synthesis service error: #{e.message}"
      render json: { error: "Verilog synthesis service is currently unavailable. Please try again later." },
             status: :service_unavailable
    rescue StandardError => e
      Rails.logger.error "Unexpected error in verilog_cv: #{e.class} - #{e.message}"
      render json: { error: "An error occurred while processing your Verilog code. Please try again later." },
             status: :internal_server_error
    end
  end
  # rubocop:enable Metrics/MethodLength

  def allow_iframe_lti
    return unless session[:is_lti]

    response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM #{session[:lms_domain]}"
  end

  private

    def allow_iframe
      response.headers.except! "X-Frame-Options"
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
# rubocop:enable Metrics/ClassLength
