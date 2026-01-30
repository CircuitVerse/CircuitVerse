# frozen_string_literal: true

class Contest < ApplicationRecord
  has_noticed_notifications model_name: "NoticedNotification"

  has_many :submissions,       dependent: :destroy
  has_many :submission_votes,  dependent: :destroy
  has_one  :contest_winner,    dependent: :destroy

  enum :status, { live: 0, completed: 1 }

  validates :deadline, presence: true
  validate  :deadline_must_be_in_future, unless: :completed?
  validates :status, presence: true
  validate  :only_one_live_contest, on: %i[create update], if: :live?
  self.per_page = 8

  private

    def deadline_must_be_in_future
      return unless deadline.present? && deadline < Time.zone.now

      errors.add(:deadline, :in_the_past, message: "must be in the future")
    end

    def only_one_live_contest
      return unless Contest.live.where.not(id: id).exists?

      errors.add(:status, :already_live, message: "Another contest is already live")
    end
end
