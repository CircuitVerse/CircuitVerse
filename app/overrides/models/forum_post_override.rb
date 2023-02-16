# frozen_string_literal: true

ForumPost.class_eval do
  after_create_commit :notify_thread_subscribers
  has_noticed_notifications model_name: "NoticedNotification", dependent: :destroy

  def notify_thread_subscribers
    forum_thread.subscribed_users.each do |sub_user|
      next if sub_user == user

      ForumCommentNotification.with(forum_post: self, forum_thread: forum_thread, user: user).deliver_later(sub_user)
    end
  end
end
