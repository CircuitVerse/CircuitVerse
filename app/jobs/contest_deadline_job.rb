# frozen_string_literal: true

class ContestDeadlineJob < ApplicationJob
  queue_as :default

  def perform(contest_id)
    contest = Contest.find_by(id: contest_id)
    return if contest.nil? || contest.completed?

    contest.with_lock do
      if Time.zone.now - contest.deadline >= 0 && contest.live?
        ShortlistContestWinner.new(contest.id).call
        contest.status = :completed
        contest.save!
      end
    end
  end
end
