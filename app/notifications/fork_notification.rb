# frozen_string_literal: true

class ForkNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    user = params[:user] if params[:user].is_a?(User)
    user ||= User.find_by(id: params[:user_id])

    project = params[:project] if params[:project].is_a?(Project)
    project ||= Project.find_by(id: params[:project_id])

    t("users.notifications.fork_notification", user: user&.name, project: project&.name)
  end

  def icon
    "fas fa-code-branch"
  end
end
