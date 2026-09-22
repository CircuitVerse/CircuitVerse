# frozen_string_literal: true

class CommentSubscription < ApplicationRecord
  belongs_to :comment_thread, foreign_key: :thread_id, inverse_of: :comment_subscriptions
  belongs_to :subscriber, polymorphic: true

  validates :subscriber_id, uniqueness: { scope: %i[subscriber_type thread_id] }
end
