# frozen_string_literal: true

class ForumThreadNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    user = params[:user] || DeletedUser.new
    thread = params[:forum_thread]
    t("users.notifications.forum_thread_notification", user: user.name, thread: thread.title.truncate_words(4))
  end

  def icon
    "far fa-comments"
  end
end
