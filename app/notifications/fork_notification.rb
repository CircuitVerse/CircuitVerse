# frozen_string_literal: true

class ForkNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    if params[:migrated] == true
      user = User.find(params[:user_id])
      forked_project = Project.find(params[:project_id])
      project = Project.find(forked_project.forked_project_id)
    else
      user = User.find(params[:user][:id])
      project = Project.find(params[:project][:id])
    end
    t("users.notifications.fork_notification", user: user.name, project: project.name)
  end

  def icon
    "fas fa-code-branch"
  end
end
