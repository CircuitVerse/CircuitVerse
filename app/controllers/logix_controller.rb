class LogixController < ApplicationController
  # before_action :authenticate_user!

  def index
      @projects = Project.select("id,author_id,image_preview,name").where(project_access_type:"Public",forked_project_id:nil).paginate(:page => params[:page]).order("id desc").limit(Project.per_page)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @projects }
        format.js
      end

  end

  def gettingStarted
  end

  def search
    @projects = Project.includes(:author).search(params[:q]).where(project_access_type:"Public",forked_project_id:nil).select("id,author_id,image_preview,name,description,view").paginate(:page => params[:page], :per_page => 2)
    render "search"
  end

  def examples
  end

  def features
  end

  def about
  end

  def all_user_index
  end

  def privacy
  end

  def tos
  end

  def teachers
  end

  def contribute
  end

end
