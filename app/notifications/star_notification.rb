# frozen_string_literal: true

class StarNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    if params[:migrated] == true
      user = User.find(params[:user_id])
      project = Project.find(params[:project_id])
    else
      user = User.find(params[:user][:id])
      project = Project.find(params[:project][:id])
    end
    t("users.notifications.star_notification", user: user.name, project: project.name)
  end

  def icon
    "far fa-star fa-thin"
  end
end
