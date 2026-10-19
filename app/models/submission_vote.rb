# frozen_string_literal: true

class SubmissionVote < ApplicationRecord
  USER_VOTES_PER_CONTEST = 3
  belongs_to :submission, counter_cache: true
  belongs_to :user
  belongs_to :contest

  validates :user_id,
            uniqueness: { scope: %i[submission_id contest_id],
                          message: "has already voted on this submission" }
  validate :cannot_vote_for_own_submission

  private

    # Validates that a user cannot vote on their own submission or project.
    #
    # @return [void]
    def cannot_vote_for_own_submission
      return if submission.blank? || user_id.blank?

      if submission.user_id == user_id || submission.project&.author_id == user_id
        errors.add(:base, "You cannot vote for your own submission")
      end
    end
end
