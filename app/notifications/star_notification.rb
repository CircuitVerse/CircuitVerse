# frozen_string_literal: true

class StarNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    user = params[:user] || DeletedUser.new
    project = params[:project] || DeletedUser.new
    t("users.notifications.star_notification", user: user.name, project: project.name)
  end

  def icon
    "far fa-star fa-thin"
  end
end
