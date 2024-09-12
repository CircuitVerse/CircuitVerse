# frozen_string_literal: true

class QuestionSubmissionHistory < ApplicationRecord
  self.primary_keys = :question_id, :user_id

  belongs_to :user
  belongs_to :question
end
