class ForumSubscription < ApplicationRecord
  belongs_to :forum_thread
  belongs_to :user

  scope :optin, -> { where(subscription_type: :optin) }
  scope :optout, -> { where(subscription_type: :optout) }

  validates :subscription_type, presence: true, inclusion: {in: %w[optin optout]}
  validates :user_id, uniqueness: {scope: :forum_thread_id}

  def toggle!
    case subscription_type
    when "optin"
      update(subscription_type: "optout")
    when "optout"
      update(subscription_type: "optin")
    end
  end
end
