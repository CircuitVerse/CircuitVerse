# frozen_string_literal: true

class Api::V1::ProjectsController < Api::V1::BaseController
  include ActionView::Helpers::SanitizeHelper

  before_action :set_project, except: [:index, :user_projects, :featured_circuits]
  before_action :authenticate_user, only: [:index]
  before_action :authenticate_user!, except: [:index]
  before_action :edit_access?, only: [:update, :destroy]
  before_action :delete_access?, only: [:destroy]
  before_action :view_access?, only: [:show]
  before_action :sanitize_name, only: [:update]
  before_action :set_options, except: [:destroy, :toggle_star]

  SORTABLE_FIELDS = ["view", "created_at"]

  # GET /api/v1/projects
  def index
    if @current_user.nil?
      @projects = Project.public_access
    else
      @projects = Project.where(
        "author_id = ? OR  project_access_type = ?", @current_user.id, "Public")
    end

    @projects = @projects.tagged_with(params[:filter][:tag]) if params.has_key?(:filter)
    @projects = @projects.order(
      Arel.sql(SortingHelper.sort_fields(params[:sort], SORTABLE_FIELDS))
    ) if params.has_key?(:sort)
    @options[:links] = link_attrs(paginate(@projects), api_v1_projects_url)

    render json: Api::V1::ProjectSerializer.new(paginate(@projects), @options)
  end

  # GET /api/v1/users/:id/projects/
  def user_projects
    if @current_user.id == params[:id].to_i
      @projects = @current_user.projects
    else
      @projects = Project.where(
        "author_id = ? AND project_access_type = ?", params[:id], "Public"
      )
    end

    @projects = @projects.tagged_with(params[:filter][:tag]) if params.has_key?(:filter)
    @projects = @projects.order(
      Arel.sql(SortingHelper.sort_fields(params[:sort], SORTABLE_FIELDS))
    ) if params.has_key?(:sort)
    @options[:links] = link_attrs(paginate(@projects), projects_api_v1_user_url)

    render json: Api::V1::ProjectSerializer.new(paginate(@projects), @options)
  end

  # GET /api/v1/projects/:id
  def show
    if @project.project_access_type == "Public" || @project.author.eql?(@current_user)
      @project.increase_views(@current_user)
      render json: Api::V1::ProjectSerializer.new(@project, @options)
    else
      api_error(status: 403, errors: "not authorized")
    end
  end

  # PATCH /api/v1/projects/:id
  def update
    @project.update!(project_params)
    if @project.update(project_params)
      render json: Api::V1::ProjectSerializer.new(@project, @options), status: :accepted
    else
      invalid_resource!(@project.errors)
    end
  end

  # DELETE /api/v1/projects/:id
  def destroy
    @project.destroy!
    render json: {}, status: :no_content
  end

  # GET /api/v1/projects/featured
  def featured_circuits
    @projects = Project.joins(:featured_circuit).all
    @projects = @projects.tagged_with(params[:filter][:tag]) if params.has_key?(:filter)
    @projects = @projects.order(
      Arel.sql(SortingHelper.sort_fields(params[:sort], SORTABLE_FIELDS))
    ) if params.has_key?(:sort)

    @options[:links] = link_attrs(paginate(@projects), api_v1_projects_featured_url)
    render json: Api::V1::ProjectSerializer.new(paginate(@projects), @options)
  end

  # GET /api/v1/projects/:id/toggle-star
  def toggle_star
    star = Star.find_by(user_id: @current_user.id, project_id: @project.id)
    if !star.nil?
      star.destroy!
      render json: { "message": "Unstarred successfully!" }, status: :ok
    else
      @star = Star.new()
      @star.user_id = @current_user.id
      @star.project_id = @project.id
      @star.save!
      render json: { "message": "Starred successfully!" }, status: :ok
    end
  end

  # /api/v1/projects/:id/fork
  def create_fork
    if @current_user.id == @project.author_id
      api_error(status: 409, errors: "Cannot fork your own project!")
    else
      @project_new = @project.dup
      @project_new.view = 1
      @project_new.author_id = @current_user.id
      @project_new.forked_project_id = @project.id
      @project_new.name = @project.name
      @project_new.save!

      render json: Api::V1::ProjectSerializer.new(@project_new, @options)
    end
  end

  private

    def set_project
      @project = Project.find(params[:id])
      @author = @project.author
    end

    def set_options
      @options = { include: [:author] }
    end

    def edit_access?
      authorize @project, :check_edit_access?
    end

    def delete_access?
      authorize @project, :author_access?
    end

    def view_access?
      authorize @project, :check_view_access?
    end

    def project_params
      params.require(:project).permit(:name, :project_access_type, :description, :tag_list)
    end

    def sanitize_name
      params[:project][:name] = sanitize(project_params[:name])
    end
end
