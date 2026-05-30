# frozen_string_literal: true

ForumThread.class_eval do
  after_create_commit :notify_moderators
  has_noticed_notifications model_name: "NoticedNotification", dependent: :destroy

  def notify_moderators
    User.where(admin: true).find_each do |moderators|
      ForumThreadNotification.with(forum_thread: self, user: user).deliver_later(moderators)
    end
  end
end
