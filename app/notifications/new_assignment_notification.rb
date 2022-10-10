# To deliver this notification:
#
# NewAssignmentNotification.with(post: @post).deliver_later(current_user)
# NewAssignmentNotification.with(post: @post).deliver(current_user)

class NewAssignmentNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
  #  user = params[:group_member.user]
  # assignment = params[:assingment]
  #  t("users.notifications.new_assignment_notification", assignment: assingment.name)
    t("users.notifications.new_assignment_notification")

  #  ForkNotification.with(user: group_member.user, assingment: @assingment).deliver_later(group_member.user_id)
  end

  def icon
    "far fa-star fa-thin"
  end

end

