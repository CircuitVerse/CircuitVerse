# frozen_string_literal: true

class UserBan < ApplicationRecord
  belongs_to :user
  belongs_to :admin, class_name: "User"
  belongs_to :report, optional: true # Links ban to the report that triggered it
  belongs_to :lifted_by, class_name: "User", optional: true # Admin who lifted the ban

  validates :reason, presence: true

  scope :active, -> { where(lifted_at: nil) }
  scope :lifted, -> { where.not(lifted_at: nil) }

  validates :user_id, presence: true # rubocop:disable Rails/RedundantPresenceValidationOnBelongsTo
  validates :admin_id, presence: true # rubocop:enable Rails/RedundantPresenceValidationOnBelongsTo

  def active?
    lifted_at.nil?
  end

  def lift!(lifted_by:)
    update(lifted_at: Time.current, lifted_by: lifted_by)
  end
end
