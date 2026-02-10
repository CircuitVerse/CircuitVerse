# frozen_string_literal: true

class ProjectDataController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_project_datum, only: [:show, :edit, :update, :destroy]

  # GET /project_data
  def index
    @project_data = ProjectDatum.all
    render json: @project_data
  end

  # GET /project_data/1
  def show
    render json: @project_datum
  end

  # GET /project_data/new
  def new
    @project_datum = ProjectDatum.new
  end

  # GET /project_data/1/edit
  def edit
  end

  # POST /project_data
  def create
    @project_datum = ProjectDatum.new(project_datum_params)

    if @project_datum.save
      render json: @project_datum, status: :created
    else
      render json: @project_datum.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /project_data/1
  def update
    if @project_datum.update(project_datum_params)
      render json: @project_datum
    else
      render json: @project_datum.errors, status: :unprocessable_entity
    end
  end

  # DELETE /project_data/1
  def destroy
    @project_datum.destroy
    head :no_content
  end

  private

  def set_project_datum
    @project_datum = ProjectDatum.find(params[:id])
  end

  def project_datum_params
    params.require(:project_datum).permit(:project_id, :data)
  end

  def require_admin
    redirect_to root_path unless current_user&.admin?
  end
end
