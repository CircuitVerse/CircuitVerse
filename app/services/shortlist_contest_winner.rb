# frozen_string_literal: true

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

        @contest.update!(status: :completed)
      end

      feature_winner_project(submission)

      ContestWinnerNotification.with(project: submission.project)
                               .deliver_later(submission.project.author)

      { success: true }
    rescue ActiveRecord::RecordNotUnique
      { success: true, message: "Winner already recorded by another worker" }
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "ShortlistContestWinner failed: #{e.message}"
      { success: false, message: e.message }
    end

    def feature_winner_project(submission)
      project = submission.project
      return unless project.project_access_type == "Public"

      FeaturedCircuit.find_or_create_by!(project: project)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
      Rails.logger.warn "ShortlistContestWinner: could not feature project #{project.id}: #{e.message}"
    end
end
