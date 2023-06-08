# frozen_string_literal: true

class Api::V1::SimulatorController < Api::V1::BaseController
  include SimulatorHelper
  include ActionView::Helpers::SanitizeHelper

  before_action :authenticate_user!, only: %i[create update edit]
  before_action :set_project, only: %i[data edit]
  before_action :set_user_project, only: %i[update]
  before_action :check_view_access, only: %i[data]
  before_action :check_edit_access, only: %i[edit update]
  # skip_before_action :verify_authenticity_token, only: %i[data create update verilogcv]

  def self.policy_class
    ProjectPolicy
  end

  # GET api/v1/simulator/:id/edit
  def edit
    render json: Api::V1::UserSerializer.new(current_user)
  end

  # GET api/v1/simulator/:id/data
  def data
    @data = ProjectDatum.find_by(project: @project)
    if @data
      render json: @data.data, status: :ok
    else
      render json: { errors: "Data not found for the specified project." }, status: :not_found
    end
  end

  # PATCH api/v1/simulator/update
  def update
    build_project_datum
    update_project_params

    if @project.save && @project.project_datum.save
      handle_image_file_cleanup
      render json: { status: "success", project: @project }, status: :ok
    else
      render json: { status: "error", errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST api/v1/simulator/create
  def create
    @project = Project.new
    @project.build_project_datum.data = sanitize_data(@project, params[:data])
    @project.name = sanitize(params[:name])
    @project.author = current_user

    image_file = return_image_file(params[:image])

    @project.image_preview = image_file
    if @project.save
      image_file.close
      File.delete(image_file) if check_to_delete(params[:image])
      render json: { status: "success", project: @project }, status: :created
    else
      render json: { status: "error", errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST api/v1/simulator/post_issue
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
    response = HTTP.post(url, json: { text: text })

    if response.success?
      render json: { status: "success", issue_circuit_data_id: issue_circuit_data_id }, status: :ok
    else
      render json: { status: "error", error: response.to_s }, status: response.code
    end
  end

  # POST api/v1/simulator/verilogcv
  def verilogcv
    url = "#{ENV.fetch('YOSYS_PATH', 'http://127.0.0.1:3040')}/getJSON"
    response = HTTP.post(url, json: { code: params[:code] })
    render json: response.to_s, status: response.code
  end

  private

    def build_project_datum
      @project.build_project_datum unless ProjectDatum.exists?(project_id: @project.id)
      @project.project_datum.data = sanitize_data(@project, params[:data])
    end

    def update_project_params
      @image_file = return_image_file(params[:image])
      @project.image_preview = @image_file
      @project.name = sanitize(params[:name])
    end

    def handle_image_file_cleanup
      @image_file.close
      File.delete(@image_file) if check_to_delete(params[:image])
    end

    def set_project
      @project = Project.friendly.find(params[:id])
    end

    # FIXME: remove this logic after fixing production data
    # def set_user_project
    #   @project = current_user.projects.friendly.find_by(id: params[:id]) || Project.friendly.find(params[:id])
    # end
    def set_user_project
      @project = current_user.projects.friendly.find(params[:id])
    end

    def check_edit_access
      authorize @project, :check_edit_access?
    end

    def check_view_access
      authorize @project, :check_view_access?
    end
end
