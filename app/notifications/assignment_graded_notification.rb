# frozen_string_literal: true

class AssignmentGradedNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    assignment = params[:assignment]
    t("users.notifications.assignment_graded_notification", assignment_name: assignment&.name || "an assignment")
  end

  def icon
    "fa fa-star"
  end
end
