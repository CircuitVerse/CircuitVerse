# frozen_string_literal: true

class StarNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  # @return [String] returns the message for the star notification
  def message
    # @type [User]
    user = params[:user]
    # @type [Project]
    project = params[:project]
    t("users.notifications.star_notification", user: user.name, project: project.name)
  end

  # @return [String] returns the font awesome icon code for the star notification
  def icon
    "far fa-star fa-thin"
  end
end
