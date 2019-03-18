class SimulatorController < ApplicationController
  include SimulatorHelper

  before_action :authenticate_user!, only: [:create, :update, :edit,:update_image]
  before_action :set_project, only: [:show, :embed, :embed, :update, :edit, :get_data,:update_image]
  before_action :check_view_access, only: [:show,:embed,:get_data]
  before_action :check_edit_access, only: [:edit,:update,:update_image]
  after_action :allow_iframe, only: :embed

  def show
    @logix_project_id = params[:id]
    @external_embed = false
    render 'embed'
  end

  def edit
    @project = Project.find_by(id:params[:id])
    @logix_project_id = params[:id]
    @projectName = @project.name
  end

  def embed
    if(@project.nil? or @project.project_access_type=="Private" )
      render plain: "Project has been moved or deleted. If you are the owner of the project, Please check your project access privileges." and return
    end
    @logix_project_id = params[:id]
    @project = Project.find(params[:id])
    @author = @project.author_id
    @external_embed = true
    render 'embed'
  end

  def get_data
    render json: @project.data
  end

  def new
    @logix_project_id = 0
    @projectName = ""
    render "edit"
  end

  def update
    @project.data = params[:data]

    image_file = return_image_file(params[:image])

    @project.image_preview = image_file
    @project.name = params[:name]
    @project.save

    if check_to_delete(params[:image])
      File.delete(image_file)
    end

    render plain: "success"
  end


  def create
    @project = Project.new
    @project.data = params[:data]
    @project.name = params[:name]
    @project.author = current_user

    image_file = return_image_file(params[:image])

    @project.image_preview = image_file
    @project.save

    if check_to_delete(params[:image])
      File.delete(image_file)
    end

    # render plain: simulator_path(@project)
    # render plain: user_project_url(current_user,@project)
    redirect_to edit_user_project_url(current_user,@project)
  end

  private
  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  def set_project
    @project = Project.find(params[:id])
  end

  def check_edit_access
    if(@project.nil? or !@project.check_edit_access(current_user))
      render plain: "Project has been moved or deleted. If you are the owner of the project, Please check your project access privileges." and return
    end
  end

  def check_view_access
    if(@project.nil? or !@project.check_view_access(current_user))
      render plain: "Project has been moved or deleted. If you are the owner of the project, Please check your project access privileges." and return
    end
  end

end
