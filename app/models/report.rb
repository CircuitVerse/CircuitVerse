# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :reporter, class_name: "User"
  belongs_to :reported_user, class_name: "User"
  has_one :user_ban, dependent: :nullify # Links to ban created from this report

  validates :reason, presence: true
  validates :status, presence: true

  # Status values
  enum :status, {
    open: "open",
    reviewed: "reviewed",
    action_taken: "action_taken",
    dismissed: "dismissed"
  }, default: :open
end
