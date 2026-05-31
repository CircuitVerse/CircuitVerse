# frozen_string_literal: true

class Projects::InvitationsController < ApplicationController
  before_action :authenticate_user!

  def show
    @project = Project.friendly.find(params.expect(:id))
    return if token_valid?

    redirect_to root_path, alert: t("projects.invite_link_invalid")
  end

  def create
    @project = Project.friendly.find(params.expect(:id))

    if token_valid?
      process_collaboration
    elsif token_matches?
      redirect_to user_project_path(@project.author, @project),
                  alert: t("projects.invitations.url_expired")
    else
      redirect_to user_project_path(@project.author, @project),
                  alert: t("projects.invitations.invalid_url")
    end
  end

  private

    def token_valid?
      token_matches? && @project.valid_token?
    end

    def token_matches?
      ActiveSupport::SecurityUtils.secure_compare(
        @project.collaboration_token.to_s,
        params[:token].to_s
      )
    end

    def process_collaboration
      if current_user.email == @project.author.email
        redirect_to user_project_path(@project.author, @project),
                    alert: t("projects.invitations.author_cannot_be_invited")
      elsif current_user.collaborations.exists?(project: @project)
        redirect_to user_project_path(@project.author, @project),
                    notice: t("projects.invitations.already_collaborator")
      else
        current_user.collaborations.create!(project: @project)
        redirect_to user_project_path(@project.author, @project),
                    notice: t("projects.invitations.collaborator_added")
      end
    end
end
