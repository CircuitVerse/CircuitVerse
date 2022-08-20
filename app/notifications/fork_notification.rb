# frozen_string_literal: true

class ForkNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    user = User.find(params[:user_id])
    project = Project.find(params[:project_id])
    t("users.notifications.fork_notification", user: user.name, project: project.name)
  end

  def icon
    "fas fa-code-branch"
  end
end
