class Api::V0::ProjectsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  before_action :set_project, only: [:show]

  before_action :check_view_access, only: [:show]

  def index
    @projects = Project.open
    response = ProjectSerializer.new(@projects).serialized_json
    render json: response
  end
  # GET /projects/1
  # GET /projects/1.json
  def show
    @project.increase_views(current_user)
    response = ProjectSerializer.new(@project).serialized_json
    render json: response
  end

  private
    def set_project
      @project = Project.find(params[:id])
      @author = @project.author
    end

    def check_view_access
      authorize @project, :view_access?
    end

    def project_params
      params.require(:project).permit(:name, :project_access_type, :description, :tag_list, :tags)
    end
end
