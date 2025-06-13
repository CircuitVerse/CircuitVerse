# frozen_string_literal: true

class ShortlistContestWinner
  def initialize(contest_id)
    @contest = Contest.find(contest_id)
  end

  def call
    submission = top_submission
    return { success: false, message: "No submissions found" } unless submission

    create_winner_for(submission)
  end

  private

    # Choose the highest-voted submission, breaking ties by earliest date.
    # If the contest received zero votes, fall back to counter-cache.

    def top_submission
      with_votes = Submission
                   .joins(:submission_votes)
                   .where(contest_id: @contest.id)
                   .group("submissions.id")
                   .order("COUNT(submission_votes.id) DESC", "submissions.created_at ASC")
                   .limit(1)
                   .first

      return with_votes if with_votes

      Submission.where(contest_id: @contest.id)
                .where("submission_votes_count > 0")
                .order("submission_votes_count DESC", "created_at ASC")
                .limit(1)
                .first
    end

    def create_winner_for(submission)
      ActiveRecord::Base.transaction do
        ContestWinner.create!(
          contest: @contest,
          submission: submission,
          project: submission.project
        )

        submission.update!(winner: true)
        FeaturedCircuit.create!(project: submission.project)
      end

      ContestWinnerNotification.with(project: submission.project)
                               .deliver_later(submission.project.author)

      { success: true }
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "ShortlistContestWinner failed: #{e.message}"
      { success: false, message: e.message }
    end
end
