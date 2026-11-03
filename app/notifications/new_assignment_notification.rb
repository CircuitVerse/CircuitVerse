# frozen_string_literal: true

class NewAssignmentNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    assignment = params.is_a?(Hash) ? params[:assignment] : nil
    t("users.notifications.new_assignment_notification", assignment_name: assignment&.name)
  end

  def icon
    "fa fa-clipboard"
  end
end
