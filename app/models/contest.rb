# frozen_string_literal: true

class Contest < ApplicationRecord
  has_noticed_notifications model_name: "NoticedNotification"

  has_many :submissions, dependent: :destroy
  has_many :submission_votes, dependent: :destroy
  has_one :contest_winner, dependent: :destroy

  enum :status, { live: 0, completed: 1 }

  validates :name, presence: true

  validates :deadline, presence: true
  validate :deadline_must_be_in_future, unless: :completed?
  validates :status, presence: true
  validate :only_one_live_contest, if: -> { live? && will_save_change_to_status? }

  self.per_page = 8

  before_validation :set_default_name
  after_commit :normalize_default_name, if: -> { @default_name_assigned }

  private

    def set_default_name
      return if name.present?

      @default_name_assigned = true
      next_number = id || (Contest.unscoped.maximum(:id).to_i + 1)

      self.name = "Contest ##{next_number}"
    end

    def normalize_default_name
      return if id.blank?

      if name == "Contest ##{id}"
        @default_name_assigned = false
        return
      end
      # rubocop:disable Rails/SkipsModelValidations
      update_column(:name, "Contest ##{id}")
      # rubocop:enable Rails/SkipsModelValidations
      @default_name_assigned = false
    end

    def deadline_must_be_in_future
      return unless deadline.present? && deadline < Time.zone.now

      errors.add(:deadline, :in_the_past, message: "must be in the future")
    end

    def only_one_live_contest
      return unless Contest.live.where.not(id: id).exists?

      errors.add(:status, :already_live, message: "Another contest is already live")
    end
end
