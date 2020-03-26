class Api::V0::PublicProjectsController < Api::V0::BaseController

  before_action :set_options

  def index
    @projects = paginate(Project.where(project_access_type: "Public"))
    @options[:meta] = meta_attributes(@projects)
    render :json => ProjectSerializer.new(@projects, @options).serialized_json
  end

  def show
    @project = Project.find(params[:id])
    render :json => ProjectSerializer.new(@project, @options).serialized_json
  end

  private

  def set_options
    @options = {}
    @options[:include] = [:author]
  end

end
