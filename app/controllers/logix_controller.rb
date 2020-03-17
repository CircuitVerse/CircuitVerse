class LogixController < ApplicationController
  # before_action :authenticate_user!

  MAXIMUM_FEATURED_CIRCUITS = 4

  def index
    @projects = Project.select("id,author_id,image_preview,name")
                       .where(project_access_type: "Public", forked_project_id: nil)
                       .paginate(page: params[:page]).order("id desc").limit(Project.per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
      format.js
    end

    @featured_circuits = Project.joins(:featured_circuit).order("featured_circuits.created_at DESC")
      .limit(MAXIMUM_FEATURED_CIRCUITS)
  end

  def gettingStarted
  end

  def examples
  end

  def features
  end

  def all_user_index
  end

  def tos
  end

  def teachers
  end

  def contribute
  end
end
