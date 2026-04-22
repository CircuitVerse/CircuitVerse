# frozen_string_literal: true

class UserBan < ApplicationRecord
  belongs_to :user
  belongs_to :admin, class_name: "User", optional: true
  belongs_to :report, optional: true
  belongs_to :lifted_by, class_name: "User", optional: true

  validates :reason, presence: true

  # rubocop:disable Rails/RedundantPresenceValidationOnBelongsTo
  validates :user_id, presence: true
  # rubocop:enable Rails/RedundantPresenceValidationOnBelongsTo

  scope :active, -> { where(lifted_at: nil) }
  scope :lifted, -> { where.not(lifted_at: nil) }

  def active?
    lifted_at.nil?
  end

  def lift!(lifted_by:)
    raise ActiveRecord::RecordInvalid, self unless active?

    update!(lifted_at: Time.current, lifted_by: lifted_by)
  end
end
