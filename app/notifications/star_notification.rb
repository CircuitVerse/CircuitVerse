# frozen_string_literal: true

class StarNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications, if: :star_notifications?

  def message
    user = params[:user]
    project = params[:project]
    t("users.notifications.star_notification", user: user.name, project: project.name)
  end

  def star_notifications?
    project = params[:project]
    recipient = project.author
    if recipient.preferences[:star]  == "true"
      return true
    else
      return false
    end    
  end

  def icon
    "far fa-star fa-thin"
  end
end
