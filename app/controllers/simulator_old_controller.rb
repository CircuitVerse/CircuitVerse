# frozen_string_literal: true

class SimulatorOldController < ApplicationController
  include SimulatorHelper
  include ActionView::Helpers::SanitizeHelper

  before_action :authenticate_user!, only: %i[create update edit update_image]
  before_action :set_project, only: %i[show embed get_data]
  before_action :set_user_project, only: %i[update edit update_image]
  before_action :check_view_access, only: %i[show embed get_data]
  before_action :check_edit_access, only: %i[edit update update_image]
  skip_before_action :verify_authenticity_token, only: %i[get_data create]
  after_action :allow_iframe, only: :embed

  def self.policy_class
    ProjectPolicy
  end

  def show
    @logix_project_id = params[:id]
    @external_embed = false
    render "embed"
  end

  def edit
    @logix_project_id = params[:id]
    @projectName = @project.name
  end

  def embed
    authorize @project
    @logix_project_id = params[:id]
    @project = Project.friendly.find(params[:id])
    @author = @project.author_id
    @external_embed = true
    render "embed"
  end

  def get_data
    render json: @project.project_datum.data
  end

  def new
    @logix_project_id = 0
    @projectName = ""
    render "edit"
  end

  def update
    @project.project_datum.data = sanitize_data(@project, params[:data])

    image_file = return_image_file(params[:image])

    @project.image_preview = image_file
    @project.name = sanitize(params[:name])
    @project.save
    @project.project_datum.save

    File.delete(image_file) if check_to_delete(params[:image])

    render plain: "success"
  end

  def post_issue
    url = ENV.fetch("SLACK_ISSUE_HOOK_URL", nil)
    HTTP.post(url, json: { text: params[:text] })
    head :ok, content_type: "text/html"
  end

  def create
    @project = Project.new
    @project.build_project_datum.data = sanitize_data(@project, params[:data])
    @project.name = sanitize(params[:name])
    @project.author = current_user

    image_file = return_image_file(params[:image])

    @project.image_preview = image_file
    @project.save!

    File.delete(image_file) if check_to_delete(params[:image])

    # render plain: simulator_path(@project)
    # render plain: user_project_url(current_user,@project)
    redirect_to edit_user_project_url(current_user, @project)
  end

  def verilog_cv
    url = "http://127.0.0.1:3040/getJSON"
    response = HTTP.post(url, json: { code: params[:code] })
    render json: response.to_s, status: response.code
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
end
