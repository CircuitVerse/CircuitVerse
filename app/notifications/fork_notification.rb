# frozen_string_literal: true

class ForkNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications, if: :fork_notifications?

  def message
    user = params[:user]
    project = params[:project]
    t("users.notifications.fork_notification", user: user.name, project: project.name)
  end

  def fork_notifications?
    project = params[:project]
    recipient = project.author
    if recipient.preferences[:fork] == "true"
      return true
    else
      return false
    end    
  end
  def icon
    "fas fa-code-branch"
  end
end
