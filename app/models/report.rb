# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :reporter, class_name: "User"
  belongs_to :reported_user, class_name: "User"
  has_one :user_ban, dependent: :nullify # Links to ban created from this report

  validates :reason, presence: true
  validates :status, presence: true
  validate :cannot_report_self

  # Status values
  enum :status, {
    open: "open",
    reviewed: "reviewed",
    action_taken: "action_taken",
    dismissed: "dismissed"
  }, default: :open

  private

    def cannot_report_self
      return unless reporter && reported_user

      errors.add(:base, "You cannot report yourself") if reporter_id == reported_user_id
    end
end
