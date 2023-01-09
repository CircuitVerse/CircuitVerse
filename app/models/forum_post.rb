# frozen_string_literal: true

# rubocop:disable all
class ForumPost < ApplicationRecord
  belongs_to :forum_thread, counter_cache: true, touch: true
  belongs_to :user
  validates :user_id, :body, presence: true

  scope :sorted, -> { order(:created_at) }

  after_update :solve_forum_thread, if: :solved?

  after_create_commit :notify_thread_subscribers
  has_noticed_notifications model_name: "NoticedNotification", dependent: :destroy

  def solve_forum_thread
    forum_thread.update(solved: true)
  end

  def notify_thread_subscribers
    forum_thread.subscribed_users.each do |sub_user|
      next if sub_user == user

      ForumCommentNotification.with(forum_post: self, forum_thread: forum_thread, user: user).deliver_later(sub_user)
    end
  end
end
