# frozen_string_literal: true

class SubmissionVote < ApplicationRecord
  belongs_to :submission, counter_cache: true
  belongs_to :user
  belongs_to :contest
end
