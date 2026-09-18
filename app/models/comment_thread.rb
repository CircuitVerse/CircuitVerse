# frozen_string_literal: true

# Mirrors Commontator::Thread. One thread per commentable, holding the comments
# and the open/closed state.
class CommentThread < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :closer, class_name: "User", optional: true

  has_many :comments, dependent: :destroy

  def closed?
    closed_at.present?
  end

  def close!(user)
    update!(closed_at: Time.current, closer: user)
  end

  def reopen!
    update!(closed_at: nil, closer: nil)
  end
end
