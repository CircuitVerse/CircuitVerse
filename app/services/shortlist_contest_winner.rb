# frozen_string_literal: true

class ShortlistContestWinner
  def initialize(contest_id)
    @contest = Contest.find(contest_id)
  end
  
  def call
    @most_voted_submission = Submission
                             .where(contest_id: @contest.id)
                             .order("submission_votes_count DESC")
                             .limit(1)
                             .first
    return if @most_voted_submission.nil?

    contest_winner = ContestWinner.new(contest_id: @contest.id, submission_id: @most_voted_submission.id,
                                       project_id: @most_voted_submission.project_id)
    contest_winner.save!
    @most_voted_submission.winner = true
    @project = Project.find(@most_voted_submission.project_id)
    FeaturedCircuit.create(project_id: @project.id)
    ContestWinnerNotification.with(project: @project).deliver_later(@project.author)
    @most_voted_submission.save!
  end
end
