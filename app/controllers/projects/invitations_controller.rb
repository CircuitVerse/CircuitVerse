# frozen_string_literal: true

class Projects::InvitationsController < ApplicationController
  before_action :authenticate_user!

  def create
    @project = Project.friendly.find(params.expect(:id))
    redirect_to user_project_path(user_id: params[:user_id], project_id: params[:project_id]),
                notice: invitation_notice
  end

  private

    def invitation_notice
      if Project.with_project_token.exists?(collaboration_token: params[:token])
        collaborator_notice
      elsif Project.exists?(collaboration_token: params[:token])
        "Url is expired, request a new one from owner of the Project."
      else
        "Invalid url"
      end
    end

    def collaborator_notice
      if current_user.email == @project.author.email
        "Author can not be invited."
      elsif current_user.collaborations.exists?(project: @project)
        "Collaborator is already present in the project."
      else
        current_user.collaborations.create!(project: @project)
        "Collaborator was successfully added."
      end
    end
end
