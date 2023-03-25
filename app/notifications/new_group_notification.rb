# frozen_string_literal: true

class NewGroupNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    @group = params[:group][:group_id]
    group = Group.find(@group)
    user = group.primary_mentor.name
    t("users.notifications.new_group_notification", group: group.name, user: user)
  end

  def icon
    "fa fa-users"
  end
end
