# frozen_string_literal: true

class Api::V0::ProjectsController < ApplicationController

  before_action :set_project, only: [:show]

  def index
    @projects = Project.open
    response = ProjectSerializer.new(@projects).serialized_json
    render json: response
  end
  # GET /projects/1
  # GET /projects/1.json
  def show
    if @project.project_access_type == "Public"
      @project.increase_views(current_user)
      response = ProjectSerializer.new(@project).serialized_json
      render json: response
    else
      render json: { errors: { title: :unauthorized,
        status: 401,
        detail: "This project is not public"}}, status: :unauthorized
    end
  end

  private
    def set_project
      @project = Project.find(params[:id])
      @author = @project.author
    end
end
