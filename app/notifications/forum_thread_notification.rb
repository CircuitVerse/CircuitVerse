# frozen_string_literal: true

class ForumThreadNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    user = params[:user]
    thread = params[:forum_thread]
    t("users.notifications.forum_thread_notification", user: user.name, thread: thread.title)
  end

  def icon
    "fa fa-comments"
  end
end
