# frozen_string_literal: true

class ForumCommentNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications

  def message
    user = params[:user] if params[:user].is_a?(User)
    user ||= User.find_by(id: params[:user_id] || params["user_id"])
    user ||= User.find_by(id: params[:user]) if params[:user].is_a?(Integer) || params[:user].is_a?(String)

    # post = params[:forum_post]
    thread = params[:forum_thread]
    t("users.notifications.comment_notif", user: user&.name, thread: thread&.title) # , mssg: post.body.truncate_words(4))
  end

  def icon
    "far fa-comment"
  end
end
