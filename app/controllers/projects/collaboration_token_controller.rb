class Projects::CollaborationTokenController < ApplicationController
  before_action :authenticate_user!

  def create
    @project = Project.friendly.find(params[:id])
    @project.reset_project_token unless @project.has_valid_token?
  end
end
