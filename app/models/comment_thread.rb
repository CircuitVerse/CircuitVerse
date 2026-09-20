# frozen_string_literal: true

class CommentThread < ApplicationRecord
  belongs_to :commontable, polymorphic: true
  belongs_to :closer, polymorphic: true, optional: true

  has_many :comments, foreign_key: :thread_id, inverse_of: :thread, dependent: :destroy
  has_many :comment_subscriptions, foreign_key: :thread_id, inverse_of: :comment_thread,
                                   dependent: :destroy

  def closed?
    !closed_at.nil?
  end
  alias is_closed? closed?

  def close(user = nil)
    return false if closed?

    self.closed_at = Time.zone.now
    self.closer = user
    save
  end

  def reopen
    return false unless closed? && !commontable.nil?

    self.closed_at = nil
    save
  end

  def subscribers
    comment_subscriptions.map(&:subscriber)
  end

  def subscription_for(subscriber)
    return nil if subscriber.nil?

    subscriber.comment_subscriptions.find_by(thread_id: id)
  end

  def subscribe(subscriber)
    return false if subscriber.nil? || subscription_for(subscriber)

    subscription = CommentSubscription.new
    subscription.subscriber = subscriber
    subscription.comment_thread = self
    subscription.save
  end

  def unsubscribe(subscriber)
    subscription = subscription_for(subscriber)
    return false unless subscription

    subscription.destroy
  end

  def can_be_read_by?(user)
    return true if can_be_edited_by?(user)
    return false if commontable.nil?
    return true if commontable.public?

    ProjectPolicy.new(user, commontable).check_view_access?
  end

  def can_be_edited_by?(user)
    !commontable.nil? && !user.nil? && user.admin?
  end

  def can_subscribe?(user)
    !closed? && !user.nil? && can_be_read_by?(user)
  end
end
