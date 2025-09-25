# frozen_string_literal: true

class StarNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    user = params[:user] if params[:user].is_a?(User)
    user ||= User.find_by(id: params[:user_id] || params["user_id"])
    user ||= User.find_by(id: params[:user]) if params[:user].is_a?(Integer) || params[:user].is_a?(String)

    project = params[:project] if params[:project].is_a?(Project)
    project ||= Project.find_by(id: params[:project_id] || params["project_id"])
    if params[:project].is_a?(Integer) || params[:project].is_a?(String)
      project ||= Project.find_by(id: params[:project])
    end

    t("users.notifications.star_notification", user: user&.name, project: project&.name)
  end

  def icon
    "far fa-star fa-thin"
  end
end
