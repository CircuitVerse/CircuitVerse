# frozen_string_literal: true

class ProjectsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include SanitizeDescription

  before_action :set_project, only: %i[show edit update destroy create_fork change_stars]
  before_action :authenticate_user!, only: %i[edit update destroy create_fork change_stars]

  before_action :check_access, only: %i[edit update destroy]
  before_action :check_delete_access, only: [:destroy]
  before_action :check_view_access, only: %i[show create_fork]
  before_action :sanitize_name, only: %i[create update]
  before_action :sanitize_project_description, only: %i[show edit]

  # GET /projects
  # GET /projects.json
  def index
    @author = User.find(params[:user_id])
  end

  # GET /projects/tags/[tag]
  def get_projects
    @projects = Project.tagged_with(params[:tag]).open.includes(:tags, :author)
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    if current_visit && !Ahoy::Event.exists?(visit_id: current_visit.id,
                                             name: "Visited project #{@project.id}")
      ahoy.track("Visited project #{@project.id}")
      @project.increase_views(current_user)
    end
    @collaboration = @project.collaborations.new
    @admin_access = true
    commontator_thread_show(@project)
  end

  # GET /projects/1/edit
  def edit; end

  def change_stars
    star = Star.find_by(user_id: current_user.id, project_id: @project.id)
    if star.nil?
      @star = Star.new
      @star.user_id = current_user.id
      @star.project_id = @project.id
      @star.save
      @star.notify :users
      render js: "2"
    else
      star.destroy
      render js: "1"
    end
  end

  def create_fork
    authorize @project
    @project_new = @project.fork(current_user)
    @project_new.save!
    @project_new.notify :users, key: "project.fork"
    redirect_to user_project_path(current_user, @project_new)
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = current_user.projects.create(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to user_project_path(@project.author_id, @project), notice: "Project was successfully created." }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    @project.description = params["description"]
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to user_project_path(@project.author_id, @project), notice: "Project was successfully updated." }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to user_path(@project.author_id), notice: "Project was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_project
      if params[:user_id]
        @author = User.find(params[:user_id])
        @project = @author.projects.friendly.find(params[:id])
      else
        @project = Project.friendly.find(params[:id])
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :project_access_type, :description, :tag_list, :tags)
    end

    def sanitize_name
      params[:project][:name] = sanitize(project_params[:name])
    end

    # Sanitize description before passing to view
    def sanitize_project_description
      @project.description = sanitize_description(@project.description)
    end
end
