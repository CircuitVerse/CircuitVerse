# frozen_string_literal: true

class ProjectsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include SanitizeDescription
  include UsersCircuitverseHelper

  before_action :set_project, only: %i[show edit update destroy create_fork change_stars]
  before_action :authenticate_user!, only: %i[edit update destroy create_fork change_stars]

  before_action :check_access, only: %i[edit update destroy]
  before_action :check_delete_access, only: [:destroy]
  before_action :check_view_access, only: %i[show create_fork]
  before_action :sanitize_name, only: %i[create update]
  before_action :sanitize_project_description, only: %i[show edit]

  def index
    @author = User.find(params[:user_id])
  end

  def show
    if current_visit && !Ahoy::Event.exists?(visit_id: current_visit.id,
                                             name: "Visited project #{@project.id}")
      ahoy.track("Visited project #{@project.id}")
      @project.increase_views(current_user)
    end
    @collaboration = @project.collaborations.new
    @admin_access = true
    commontator_thread_show(@project)
    @embed_path = simulator_path(@project)
  end

  def edit; end

  def change_stars
    # Preserve existing response contract:
    # - "2" => star created (icon becomes filled, star-count +1)
    # - "1" => star removed (icon becomes outline, star-count -1)
    starred = @project.toggle_star(current_user)
    render js: (starred ? "2" : "1")
  end

  def create_fork
    authorize @project
    @project_new = @project.fork(current_user)
    @project_new.save!
    redirect_to user_project_path(current_user, @project_new)
  end

  def create
    @project = current_user.projects.create(project_params)
    respond_to do |format|
      if @project.save
        format.html do
          redirect_to user_project_path(@project.author_id, @project),
                      notice: "Project was successfully created."
        end
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_content }
      end
    end
  end

  def update
    @project.description = params["description"]
    set_name_project_datum(project_params)
    respond_to do |format|
      if @project.update(project_params)
        format.html do
          redirect_to user_project_path(@project.author_id, @project),
                      notice: "Project was successfully updated."
        end
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @project.destroy
    respond_to do |format|
      format.html do
        redirect_to user_path(@project.author_id),
                    notice: "Project was successfully destroyed."
      end
      format.json { head :no_content }
    end
  end

  private

  def set_project
    if params[:user_id]
      @author = User.find(params[:user_id])
      @project = @author.projects.friendly.with_attached_circuit_preview.find(params[:id])
    else
      @project = Project.friendly.with_attached_circuit_preview.find(params[:id])
      @author = @project.author
    end
  end

  def check_access
    authorize @project, :edit_access?
  end

  def check_delete_access
    authorize @project, :author_access?
  end

  def check_view_access
    authorize @project, :view_access?
  end

  def project_params
    params.expect(project: %i[name project_access_type description tag_list tags])
  end

  def sanitize_name
    params[:project][:name] = sanitize(project_params[:name])
  end

  def sanitize_project_description
    @project.description = sanitize_description(@project.description)
  end

  def set_name_project_datum(project_params)
    return unless @project.project_datum

    datum_data = JSON.parse(@project.project_datum.data)
    datum_data["name"] = project_params["name"]
    @project.project_datum.data = JSON.generate(datum_data)
  end
end