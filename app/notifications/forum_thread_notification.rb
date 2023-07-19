# frozen_string_literal: true

class ForumThreadNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  # @return [String] returns the message to be displayed in the notification
  def message
    # @type [User]
    user = params[:user]
    thread = params[:forum_thread]
    t("users.notifications.forum_thread_notification", user: user.name, thread: thread.title.truncate_words(4))
  end

  # @return [String] returns the fontawesome icon for the forum thread notification
  def icon
    "far fa-comments"
  end
end
