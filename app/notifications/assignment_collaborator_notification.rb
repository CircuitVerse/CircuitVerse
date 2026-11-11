# frozen_string_literal: true

class AssignmentCollaboratorNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    assignment = params[:assignment]
    t("users.notifications.assignment_collaborator_notification",
      user: params[:user]&.name,
      assignment_name: assignment&.name,
      group: assignment&.group&.name,
      deadline: assignment&.deadline&.to_fs(:long))
  end

  def icon
    "fas fa-user-plus"
  end
end
