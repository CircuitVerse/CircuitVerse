# frozen_string_literal: true

class Projects::CollaborationTokenController < ApplicationController
  before_action :authenticate_user!

  def create
    @project = Project.friendly.find(params.expect(:id))
    @project.reset_project_token unless @project.valid_token?
  end
end
