# frozen_string_literal: true

class Contest < ApplicationRecord
  has_noticed_notifications model_name: "NoticedNotification"
  has_many  :submissions,        dependent: :destroy
  has_many  :submission_votes,   dependent: :destroy
  has_one   :contest_winner,     dependent: :destroy
  after_commit :set_deadline_job

  enum status: { live: 0, completed: 1 }

  def display_name
    (try(:name).presence || try(:title).presence || "Weekly Contest ##{id}")
  end

  def set_deadline_job
    return if completed?

    ContestDeadlineJob.set(wait: ((deadline - Time.zone.now) / 60).minute).perform_later(id)
  end

  self.per_page = 8
end
