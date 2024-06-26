# frozen_string_literal: true

class SimulatorController < ApplicationController
  include SimulatorHelper
  include ActionView::Helpers::SanitizeHelper

  before_action :redirect_to_vue_simulator_if_enabled
  before_action :authenticate_user!, only: %i[create update edit update_image]
  before_action :set_project, only: %i[show embed get_data]
  before_action :set_user_project, only: %i[update edit update_image]
  before_action :check_view_access, only: %i[show embed get_data]
  before_action :check_edit_access, only: %i[edit update update_image]
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
    render "embed"
  end

  def new
    if Rails.configuration.simulator_version == "1.0"
      @logix_project_id = 0
      @projectName = ""
      render "edit"
    else
      render file: Rails.public_path.join("simulatorvue", "index.html"), layout: false
    end
  end

  def edit
    @logix_project_id = params[:id]
    @projectName = @project.name

    if @project.version == "1.0"
      render "edit"
    elsif @project.version == "2.0"
      render file: Rails.public_path.join("simulatorvue", "index.html"), layout: false
    end
  end

  def embed
    authorize @project
    @logix_project_id = params[:id]
    @project = Project.friendly.find(params[:id])
    @author = @project.author_id
    @external_embed = true
    # TODO: embed based on the version
    render "embed"
  end

  def get_data
    render json: ProjectDatum.find_by(project: @project)&.data
  end

  def create
    @project = Project.new
    @project.build_project_datum.data = sanitize_data(@project, params[:data])
    @project.name = sanitize(params[:name])
    @project.author = current_user
    @project.version = Rails.configuration.simulator_version
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

  def verilog_cv
    url = "#{ENV.fetch('YOSYS_PATH', 'http://127.0.0.1:3040')}/getJSON"
    response = HTTP.post(url, json: { code: params[:code] })
    render json: response.to_s, status: response.code
  end

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

    # FIXME: remove this logic after fixing production data
    def set_user_project
      @project = current_user.projects.friendly.find_by(id: params[:id]) || Project.friendly.find(params[:id])
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

    def redirect_to_vue_simulator_if_enabled
      return unless Flipper.enabled?(:vuesim, current_user)

      new_path = request.fullpath.gsub(%r{^/simulator}, "")
      if new_path.blank? || new_path == "/"
        redirect_to default_simulatorvue_path
      else
        redirect_to simulatorvue_path(path: new_path.sub(%r{^/}, ""))
      end
    end
end
