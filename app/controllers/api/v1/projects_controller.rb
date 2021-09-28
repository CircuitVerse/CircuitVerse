# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Api::V1::ProjectsController < Api::V1::BaseController
  include ActionView::Helpers::SanitizeHelper

  before_action :authenticate_user!, only: %i[update destroy toggle_star create_fork]
  before_action :load_index_projects, only: %i[index]
  before_action :load_user_projects, only: %i[user_projects]
  before_action :load_featured_circuits, only: %i[featured_circuits]
  before_action :load_user_favourites, only: %i[user_favourites]
  before_action :set_project, only: %i[show update destroy toggle_star create_fork]
  before_action :set_options, except: %i[destroy toggle_star image_preview]
  before_action :filter, only: %i[index user_projects featured_circuits user_favourites]
  before_action :sort, only: %i[index user_projects featured_circuits user_favourites]

  SORTABLE_FIELDS = %i[view created_at].freeze
  WHITELISTED_INCLUDE_ATTRIBUTES = %i[author collaborators].freeze

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

  # GET /api/v1/users/:id/favourites
  def user_favourites
    @options[:links] = link_attrs(paginate(@projects), favourites_api_v1_user_url)
    render json: Api::V1::ProjectSerializer.new(paginate(@projects), @options)
  end

  # GET /api/v1/projects/:id
  def show
    authorize @project, :check_view_access?
    @project.increase_views(current_user)
    render json: Api::V1::ProjectSerializer.new(@project, @options)
  end

  def image_preview
    @project = Project.open.friendly.find(params[:id])
    render json: { "project_preview": request.base_url + @project.image_preview.url }
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
    if @project.toggle_star(current_user)
      render json: { "message": "Starred successfully!" }, status: :ok
    else
      render json: { "message": "Unstarred successfully!" }, status: :ok
    end
  end

  # /api/v1/projects/:id/fork
  def create_fork
    if current_user.id == @project.author_id
      api_error(status: 409, errors: "Cannot fork your own project!")
    else
      @forked_project = @project.fork(current_user)
      render json: Api::V1::ProjectSerializer.new(@forked_project, @options)
    end
  end

  private

    def set_project
      if params[:user_id]
        @author = User.find(params[:user_id])
        @project = @author.projects.friendly.find(params[:id])
      else
        @project = Project.friendly.find(params[:id])
        @author = @project.author
      end
    end

    def load_index_projects
      @projects = if current_user.nil?
        Project.open
      else
        Project.open.or(Project.by(current_user.id))
      end
    end

    def load_user_projects
      # if user is not authenticated or authenticated as some other user
      # return only user's public projects else all
      @projects = if current_user.nil? || current_user.id != params[:id].to_i
        Project.open.by(params[:id])
      else
        current_user.projects
      end
    end

    def load_user_favourites
      @projects = Project.joins(:stars)
                         .where(stars: { user_id: params[:id].to_i })

      # if user is not authenticated or authenticated as some other user
      # return only user's public favourites else all
      @projects = if current_user.nil? || current_user.id != params[:id].to_i
        @projects.open
      else
        @projects
      end
    end

    def load_featured_circuits
      @projects = Project.joins(:featured_circuit).all
    end

    # include=author
    def include_resource
      params[:include].split(",")
                      .map { |resource| resource.strip.to_sym }
                      .select { |resource| WHITELISTED_INCLUDE_ATTRIBUTES.include?(resource) }
    end

    def set_options
      @options = {}
      @options[:include] = include_resource if params.key?(:include)
      @options[:params] = {
        current_user: current_user,
        only_name: true
      }
    end

    def filter
      @projects = @projects.tagged_with(params[:filter][:tag]) if params.key?(:filter)
    end

    def sort
      return unless params.key?(:sort)

      @projects = @projects.order(SortingHelper.sort_fields(params[:sort], SORTABLE_FIELDS))
    end

    def project_params
      params.require(:project).permit(:name, :project_access_type, :description, :tag_list)
    end
end
# rubocop:enable Metrics/ClassLength
