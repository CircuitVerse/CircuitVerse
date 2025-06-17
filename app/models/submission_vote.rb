# frozen_string_literal: true

class SubmissionVote < ApplicationRecord
  USER_VOTES_PER_CONTEST = 3
  belongs_to :submission, counter_cache: true
  belongs_to :user
  belongs_to :contest

  validates :user_id,
            uniqueness: { scope: %i[submission_id contest_id],
                          message: "has already voted on this submission" }
end
