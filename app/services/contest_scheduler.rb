# frozen_string_literal: true

class ContestScheduler
  def self.call(contest)
    return if contest.completed?
    return unless contest.deadline.present?

    wait_seconds = [(contest.deadline - Time.zone.now).to_i, 0].max
    ContestDeadlineJob.set(wait: wait_seconds.seconds).perform_later(contest.id)
  end
end
