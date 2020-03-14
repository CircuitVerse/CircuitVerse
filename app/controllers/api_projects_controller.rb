class ApiProjectsController < ApplicationController

  def index
    @projects = Project.find_by(project_access_type: "Public")
    render json: @projects
  end

  def show
    @project = Project.find(params[:id])
    render json: @project
  end

end
