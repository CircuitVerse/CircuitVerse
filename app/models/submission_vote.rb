# frozen_string_literal: true

class SubmissionVote < ApplicationRecord
  belongs_to :submission
  belongs_to :user
end