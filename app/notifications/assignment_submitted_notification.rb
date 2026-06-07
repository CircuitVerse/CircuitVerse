# frozen_string_literal: true

class AssignmentSubmittedNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    assignment = params[:assignment]
    t("users.notifications.assignment_submitted_notification", assignment_name: assignment&.name || "an assignment")
  end

  def icon
    "fa fa-check-circle"
  end
end
