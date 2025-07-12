# frozen_string_literal: true

class ContestLeaderboardQuery
  def self.call(contest)
    contest
      .submissions
      .left_joins(:submission_votes)
      .select("submissions.*, COUNT(submission_votes.id) AS votes_count")
      .group("submissions.id")
      .order(Arel.sql("COUNT(submission_votes.id) DESC, submissions.created_at ASC"))
  end
end
