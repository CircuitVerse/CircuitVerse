# frozen_string_literal: true

class ForkNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    user = params[:user] || DeletedUser.new
    project = params[:project] || DeletedProject.new
    t("users.notifications.fork_notification", user: user.name, project: project.name)
  end

  def icon
    "fas fa-code-branch"
  end
end
