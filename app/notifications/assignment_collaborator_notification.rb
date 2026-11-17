# frozen_string_literal: true

class AssignmentCollaboratorNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  # Builds the localized message for the notification.
  # @return [String]
  def message
    assignment = params[:assignment]
    t("users.notifications.assignment_collaborator_notification",
      user: params[:user],
      assignment_name: assignment&.name,
      group: assignment&.group&.name,
      deadline: assignment&.deadline&.strftime("%B %d, %Y %H:%M %:z"))
  end

  def icon
    "fas fa-user-plus"
  end
end
