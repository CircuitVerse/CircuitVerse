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

    @featured_circuits = Project.joins(:featured_circuit).limit(MAXIMUM_FEATURED_CIRCUITS)
  end

  def gettingStarted
  end

  def search
    @projects = projects_scope
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

  private
    def projects_scope
      public_and_not_forked_projects = ProjectsQuery.new.public_and_not_forked
      ProjectsQuery.new(public_and_not_forked_projects)
        .search_name_description(params[:q]).paginate(page: params[:page], per_page: 5)
    end

end
