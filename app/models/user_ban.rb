# frozen_string_literal: true

class UserBan < ApplicationRecord
  belongs_to :user
  belongs_to :admin, class_name: 'User'
  belongs_to :report, optional: true  # Links ban to the report that triggered it

  validates :reason, presence: true
  validates :user_id, presence: true
  validates :admin_id, presence: true

  scope :active, -> { where(lifted_at: nil) }
  scope :lifted, -> { where.not(lifted_at: nil) }

  def active?
    lifted_at.nil?
  end

  def lift!(lifted_by:)
    update(lifted_at: Time.current)
  end
end
