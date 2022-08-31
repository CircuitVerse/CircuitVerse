# frozen_string_literal: true

class StarNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications
  deliver_by :webpush, class: "DeliveryMethods::Webpush"

  def message
    user = User.find(params[:user_id])
    project = Project.find(params[:project_id])
    t("users.notifications.star_notification", user: user.name, project: project.name)
  end

  def icon
    "far fa-star fa-thin"
  end
end
