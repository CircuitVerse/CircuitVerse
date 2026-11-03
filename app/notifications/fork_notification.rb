# frozen_string_literal: true

class ForkNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    user = params.is_a?(Hash) ? params[:user] : nil
    project = params.is_a?(Hash) ? params[:project] : nil
    t("users.notifications.fork_notification", user: user&.name, project: project&.name)
  end

  def icon
    "fas fa-code-branch"
  end
end
