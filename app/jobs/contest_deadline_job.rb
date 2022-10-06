# frozen_string_literal: true

class ContestDeadlineJob < ApplicationJob
  queue_as :default

  def perform(contest_id)
    contest = Contest.find_by(id: contest_id)
    return if contest.nil? || (contest.status != "Live")

    contest.with_lock do
      if Time.zone.now - contest.deadline >= -10 && (contest.status == "Live")
        most_voted_submission = Submission.where(contest_id: contest_id)
                                          .order("submission_votes_count DESC")
                                          .limit(1)
                                          .first
        if !most_voted_submission.nil?
          most_voted_submission.winner = true
          project = Project.find(most_voted_submission.project_id)
          FeaturedCircuit.create(project_id: project.id)
          ContestWinnerNotification.with(project: project).deliver_later(project.author)
          most_voted_submission.save!
        end
        contest.status = "Completed"
        contest.save!
      end
    end
  end
end
