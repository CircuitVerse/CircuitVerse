# frozen_string_literal: true

class ForkNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    user = params[:user].is_a?(Array) ? params[:user].first : params[:user]
    project = params[:project]
    t("users.notifications.fork_notification", user: user&.name, project: project&.name)
  end

  def icon
    "fas fa-code-branch"
  end
end
