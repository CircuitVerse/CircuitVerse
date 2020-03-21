# frozen_string_literal: true

class Api::V0::ProjectsController < ApplicationController
  def index
    @projects = Project.all
    json_string = ProjectsSerializer.new(@projects).serialized_json
    render json: json_string
  end

  def show
    @projects = Project.find(params[:id])
    if @projects.project_access_type == "Public"
      json_string = ProjectsSerializer.new(@projects).serialized_json
      render json: json_string
    else
      render plain: "The record you wish access could not be found"
    end
  end
end
