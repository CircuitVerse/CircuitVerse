# frozen_string_literal: true

class ForkNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    unless params.is_a?(Hash)
      Rails.logger.warn("ForkNotification received non-hash params: #{params.inspect}")
      return "You have a new fork notification"
    end

    user = params[:user]
    project = params[:project]

    t(
      "users.notifications.fork_notification",
      user: user&.name || "Someone",
      project: project&.name || "your project"
    )
  end

  def icon
    "fas fa-code-branch"
  end
end
