# frozen_string_literal: true

class ForkNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  # @return [String] returns the message to be displayed
  def message
    # @type [User]
    user = params[:user]
    # @type [Project]
    project = params[:project]
    t("users.notifications.fork_notification", user: user.name, project: project.name)
  end

  # @return [String] returns the fontawesome icon code
  def icon
    "fas fa-code-branch"
  end
end
