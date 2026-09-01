# frozen_string_literal: true

# Mirrors Commontator::Comment. Belongs to a thread rather than directly to the
# commentable, so that thread level state (open/closed, subscriptions) has a
# home and the existing API shape is preserved.
class Comment < ApplicationRecord
  BODY_MAX_LENGTH = 10_000

  belongs_to :comment_thread, inverse_of: :comments
  belongs_to :user
  belongs_to :editor, class_name: "User", optional: true
  belongs_to :parent, class_name: "Comment", optional: true

  has_many :replies, class_name: "Comment",
                     foreign_key: :parent_id,
                     inverse_of: :parent,
                     dependent: :destroy

  validates :body, presence: true, length: { maximum: BODY_MAX_LENGTH }
  validate :parent_shares_thread

  scope :kept, -> { where(deleted_at: nil) }
  scope :roots, -> { where(parent_id: nil) }
  scope :chronological, -> { order(created_at: :asc) }

  def deleted?
    deleted_at.present?
  end

  def edited?
    editor_id.present?
  end

  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def restore!
    update!(deleted_at: nil)
  end

  private

    # A reply must live in the same thread as its parent, otherwise a comment
    # could be threaded onto a discussion it does not belong to.
    def parent_shares_thread
      return if parent.nil?
      return if parent.comment_thread_id == comment_thread_id

      errors.add(:parent, "must belong to the same thread")
    end
end
