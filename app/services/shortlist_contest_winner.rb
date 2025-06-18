# frozen_string_literal: true

# Picks the top-voted submission, marks it as the winner, and closes the contest.
# Idempotent: a DB-level `UNIQUE` index on `contest_winners.contest_id` together
# with an `ActiveRecord::RecordNotUnique` rescue guarantees only one winner row.
class ShortlistContestWinner
  def initialize(contest_id)
    @contest = Contest.find(contest_id)
  end

  def call
    return { success: false, message: "Contest already completed" } if @contest.completed?

    submission = top_submission
    return { success: false, message: "No submissions found" } unless submission

    create_winner_for(submission)
  end

  private

    # Returns the highest-voted submission for the contest.
    # Uses a single LEFT JOIN so it also works when every submission has zero votes:
    #   1. Sort by vote-count (DESC)
    #   2. Tie-break by earliest creation date
    def top_submission
      Submission
        .left_joins(:submission_votes)
        .where(contest_id: @contest.id)
        .group("submissions.id")
        .order(Arel.sql("COUNT(submission_votes.id) DESC"), :created_at)
        .first
    end

    def create_winner_for(submission)
      ActiveRecord::Base.transaction do
        ContestWinner.create!(contest: @contest, submission: submission, project: submission.project)

        submission.update!(winner: true)
        FeaturedCircuit.create!(project: submission.project)

        @contest.update!(status: :completed)
      end

      ContestWinnerNotification.with(project: submission.project)
                               .deliver_later(submission.project.author)

      { success: true }
    rescue ActiveRecord::RecordNotUnique
      { success: true, message: "Winner already recorded by another worker" }
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "ShortlistContestWinner failed: #{e.message}"
      { success: false, message: e.message }
    end
end
