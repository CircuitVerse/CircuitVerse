# frozen_string_literal: true

class Api::V0::ProjectsController < Api::V0::BaseController
  before_action :set_project, only: [:show]

  def index
    @projects = Project.all.paginate(page: params[:page], per_page: per_page)
    options = { links: links, meta: meta }
    if request.headers["Content-Type"] == "application/vnd.api+json"
      if request.headers["Accept"] == "application/vnd.api+json"
        render json: Api::V0::ProjectSerializer.new(@projects, options).serialized_json, status: :ok
      else
        render json: { errors: [{ id: "1", status: 406, title: "Not Acceptable",
          detail: "The request is not acceptable" }] }, status: :not_acceptable
      end
    else
      render json: { errors: [{ id: "1", status: "415", title: "Unsupported Media Type",
        detail: "Kindly check Request headers" },] }, status: :unsupported_media_type
    end
  end

  def show
    if @project.project_access_type == "Public"
      @project.increase_views(current_user)
      render json: Api::V0::ProjectSerializer.new(@project), status: :ok
    else
      render json: { errors: [{ title: :unauthorized,
        status: 401,
        detail: "This project is not public" }] }, status: :unauthorized
    end
  end

  private

    def set_project
      @project = Project.find(params[:id])
      @author = @project.author
    end

    def current_page
      (params[:page] || 1).to_i
    end

    def per_page
      (params[:per_page] || 2).to_i
    end

    def project_params
      params.require(:project).permit(:name, :project_access_type, :description, :tag_list, :tags)
    end

    def links
      links_json = {
        first: api_v0_projects_path(per_page: per_page),
        self: api_v0_projects_path(page: current_page, per_page: per_page),
        next: api_v0_projects_path(page: current_page + 1, per_page: per_page),
        last: api_v0_projects_path(page: @projects.total_pages, per_page: per_page)
      }
      links_json
    end

    def meta
      meta_json = {
        current_page: :page,
        total_pages: @projects.total_pages
      }
      meta_json
    end
end
