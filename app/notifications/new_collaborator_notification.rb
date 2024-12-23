# frozen_string_literal: true

class NewCollaboratorNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    user = params[:user]&.name
    project = params[:project]&.name
    t("users.notifications.new_collaborator_notification", user: user, project: project)
  end

  def icon
    "fa fa-user-plus fa-thin"
  end
end
