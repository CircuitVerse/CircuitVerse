# frozen_string_literal: true

# Picks the top-voted submission, marks it as the winner, and closes the contest.
# Idempotent: a DB-level `UNIQUE` index on `contest_winners.contest_id` together
# with `ActiveRecord::RecordNotUnique` rescue guarantees only one winner row.
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

    # Choose the highest-voted submission, breaking ties by earliest creation.
    # If every submission has zero votes, fall back to the vote counter-cache.
    def top_submission
      with_votes = Submission
                   .joins(:submission_votes)
                   .where(contest_id: @contest.id)
                   .group("submissions.id")
                   .order("COUNT(submission_votes.id) DESC", "submissions.created_at ASC")
                   .limit(1)
                   .first
      return with_votes if with_votes

      Submission
        .where(contest_id: @contest.id)
        .where("submission_votes_count > 0")
        .order("submission_votes_count DESC", "created_at ASC")
        .limit(1)
        .first
    end

    def create_winner_for(submission)
      ActiveRecord::Base.transaction do
        ContestWinner.create!(contest: @contest, submission: submission, project: submission.project)

        submission.update!(winner: true)
        FeaturedCircuit.create!(project: submission.project)

        # Mark the contest as completed in the same transaction for atomicity
        @contest.update!(status: :completed)
      end

      ContestWinnerNotification.with(project: submission.project)
                               .deliver_later(submission.project.author)

      { success: true }
    rescue ActiveRecord::RecordNotUnique
      # Another worker finished first – safely treat as success
      { success: true, message: "Winner already recorded by another worker" }
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "ShortlistContestWinner failed: #{e.message}"
      { success: false, message: e.message }
    end
end
