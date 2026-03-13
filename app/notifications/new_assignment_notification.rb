# frozen_string_literal: true

class NewAssignmentNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  # @return [String] returns the message to be displayer of the notification
  def message
    # @type [Assignment]
    assignment = params[:assignment]
    t("users.notifications.new_assignment_notification", assignment_name: assignment.name)
  end

  # @return [String] returns the fontawesome icon for the new assignment notification
  def icon
    "fa fa-clipboard"
  end
end
