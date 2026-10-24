# frozen_string_literal: true

class ContestDeadlineJob < ApplicationJob
  queue_as :default

  def perform(contest_id)
    contest = Contest.find_by(id: contest_id)
    return if contest.nil? || contest.completed?

    contest.with_lock do
      next unless contest.live? && contest.deadline <= Time.zone.now

      result = ShortlistContestWinner.new(contest.id).call
      contest.reload

      if result[:success] || result[:message] == "Contest already completed"
        next
      elsif result[:message] == "No submissions found" && contest.live?
        contest.update!(status: :completed)
      else
        Rails.logger.error "ContestDeadlineJob: winner selection failed for contest #{contest.id}: #{result[:message]}"
        raise ActiveRecord::Rollback
      end
    end
  end
end
