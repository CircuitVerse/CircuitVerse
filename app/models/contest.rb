# frozen_string_literal: true

class Contest < ApplicationRecord
  has_noticed_notifications model_name: "NoticedNotification"
  has_many :submissions, dependent: :destroy
  has_many :submission_votes, dependent: :destroy
  after_commit :set_deadline_job

  def set_deadline_job
    if status != "Completed"
      ContestDeadlineJob.set(wait: ((deadline - Time.zone.now) / 60).minute).perform_later(id)
    end
  end

  self.per_page = 8
end
