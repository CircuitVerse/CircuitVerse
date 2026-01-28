# frozen_string_literal: true

class NewAssignmentNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    assignment = params[:assignment] || DeletedUser.new
    t("users.notifications.new_assignment_notification", assignment_name: assignment.name)
  end

  def icon
    "fa fa-clipboard"
  end
end
