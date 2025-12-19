# frozen_string_literal: true

class ForumThreadNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    user = params[:user] if params[:user].is_a?(User)
    user ||= User.find_by(id: params[:user_id] || params["user_id"])
    user ||= User.find_by(id: params[:user]) if params[:user].is_a?(Integer) || params[:user].is_a?(String)

    thread = params[:forum_thread]
    t("users.notifications.forum_thread_notification", user: user&.name, thread: thread&.title&.truncate_words(4))
  end

  def icon
    "far fa-comments"
  end
end
