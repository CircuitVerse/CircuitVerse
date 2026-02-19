# frozen_string_literal: true

class ForkNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    user = params[:user]
    project = params[:project]

    t(
      "users.notifications.fork_notification",
      user: user&.name.presence || t("users.notifications.deleted_user"),
      project: project&.name.presence || t("users.notifications.deleted_project")
    )
  end

  def icon
    "fas fa-code-branch"
  end
end
