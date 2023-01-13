# frozen_string_literal: true

class NewAssignmentNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications, if: :new_assignment_notification?

  def message
    assignment = params[:assignment]
    t("users.notifications.new_assignment_notification", assignment_name: assignment.name)
  end

  def new_assignment_notification?
    return true if recipient.preferences[:new_assignment] == "true"

    false
  end

  def icon
    "fa fa-clipboard"
  end
end
