# frozen_string_literal: true

class Api::V1::ProjectsController < Api::V1::BaseController
  include ActionView::Helpers::SanitizeHelper

  before_action :authenticate_user, only: %i[index show]
  before_action :authenticate_user!, except: %i[index show]
  before_action :load_index_projects, only: %i[index]
  before_action :load_user_projects, only: %i[user_projects]
  before_action :load_featured_circuits, only: %i[featured_circuits]
  before_action :set_project, only: %i[show update destroy toggle_star create_fork]
  before_action :set_options, except: %i[destroy toggle_star]
  before_action :filter, only: %i[index user_projects featured_circuits]
  before_action :sort, only: %i[index user_projects featured_circuits]

  SORTABLE_FIELDS = %i[view created_at].freeze

  # GET /api/v1/projects
  def index
    @options[:links] = link_attrs(paginate(@projects), api_v1_projects_url)
    render json: Api::V1::ProjectSerializer.new(paginate(@projects), @options)
  end

  # GET /api/v1/users/:id/projects/
  def user_projects
    @options[:links] = link_attrs(paginate(@projects), projects_api_v1_user_url)
    render json: Api::V1::ProjectSerializer.new(paginate(@projects), @options)
  end

  # GET /api/v1/projects/:id
  def show
    authorize @project, :check_view_access?
    @project.increase_views(@current_user)
    render json: Api::V1::ProjectSerializer.new(@project, @options)
  end

  # PATCH /api/v1/projects/:id
  def update
    authorize @project, :check_edit_access?
    params[:project][:name] = sanitize(project_params[:name])
    @project.update!(project_params)
    if @project.update(project_params)
      render json: Api::V1::ProjectSerializer.new(@project, @options), status: :accepted
    else
      invalid_resource!(@project.errors)
    end
  end

  # DELETE /api/v1/projects/:id
  def destroy
    authorize @project, :author_access?
    @project.destroy!
    render json: {}, status: :no_content
  end

  # GET /api/v1/projects/featured
  def featured_circuits
    @options[:links] = link_attrs(paginate(@projects), api_v1_projects_featured_url)
    render json: Api::V1::ProjectSerializer.new(paginate(@projects), @options)
  end

  # GET /api/v1/projects/:id/toggle-star
  def toggle_star
    if @project.toggle_star(@current_user)
      render json: { "message": "Starred successfully!" }, status: :ok
    else
      render json: { "message": "Unstarred successfully!" }, status: :ok
    end
  end

  # /api/v1/projects/:id/fork
  def create_fork
    if @current_user.id == @project.author_id
      api_error(status: 409, errors: "Cannot fork your own project!")
    else
      @forked_project = @project.fork(@current_user)
      render json: Api::V1::ProjectSerializer.new(@forked_project, @options)
    end
  end

  private

    def set_project
      @project = Project.find(params[:id])
      @author = @project.author
    end

    def load_index_projects
      @projects = if @current_user.nil?
        Project.open
      else
        Project.open.or(Project.by(@current_user.id))
      end
    end

    def load_user_projects
      @projects = if @current_user.id == params[:id].to_i
        @current_user.projects
      else
        Project.open.by(params[:id])
      end
    end

    def load_featured_circuits
      @projects = Project.joins(:featured_circuit).all
    end

    def set_options
      @options = { include: [:author] }
    end

    def project_params
      params.require(:project).permit(:name, :project_access_type, :description, :tag_list)
    end

    def filter
      @projects = @projects.tagged_with(params[:filter][:tag]) if params.key?(:filter)
    end

    def sort
      return unless params.key?(:sort)

      @projects = @projects.order(SortingHelper.sort_fields(params[:sort], SORTABLE_FIELDS))
    end
end
