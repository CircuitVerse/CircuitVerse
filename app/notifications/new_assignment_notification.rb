# frozen_string_literal: true

class NewAssignmentNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    # user = params[:group_member.user]
    assignment = params[:assignment]
    # t("users.notifications.new_assignment_notification", assignment: assingment.name)
    t("users.notifications.new_assignment_notification", assignment_name: assignment.name)
  end

  def icon
    "fa fa-clipboard"
  end
end
