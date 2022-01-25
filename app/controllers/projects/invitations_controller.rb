class Projects::InvitationsController < ApplicationController
    def create
        @project = Project.friendly.find(params[:id])
        if Project.with_project_token.exists?(collaboration_token: params[:token])
            if current_user&.email == @project.author.email
                notice = "Author can not be invited."
            elsif current_user&.collaborations.exists?(project: @project)
              notice = "Collaborator is already present in the project."
            else
              current_user.collaborations.create!(project: @project)
              notice = "Collaborator was successfully added."
            end
          elsif Project.exists?(collaboration_token: params[:token])
            notice = "Url is expired, request a new one from owner of the Project."
          else
            notice = "Invalid url"
          end
          redirect_to user_project_path(user_id: params[:user_id], project_id: params[:project_id]), notice: notice
    end
end
