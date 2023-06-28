class Commontator::Subscription < ActiveRecord::Base
  belongs_to :subscriber, polymorphic: true
  belongs_to :thread, inverse_of: :subscriptions

  validates :thread, presence: true, uniqueness: { scope: [ :subscriber_type, :subscriber_id ] }

  def self.comment_created(comment)
    recipients = comment.thread.subscribers.reject { |sub| sub == comment.creator }
    return if recipients.empty?

    mail = Commontator::SubscriptionsMailer.comment_created(comment, recipients)
    mail.respond_to?(:deliver_later) ? mail.deliver_later : mail.deliver
  end

  def unread_comments(show_all)
    created_at = Commontator::Comment.arel_table[:created_at]
    thread.filtered_comments(show_all).where(created_at.gteq(updated_at))
  end
end
