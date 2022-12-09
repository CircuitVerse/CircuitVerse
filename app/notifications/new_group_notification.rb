# frozen_string_literal: true

class NewGroupNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    group = params[:group][:group_id]
    t("users.notifications.new_group_notification", group: group)
  end

  def icon
    "far fa-clipboard"
  end
end
