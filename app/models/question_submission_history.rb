# frozen_string_literal: true

class QuestionSubmissionHistory < ApplicationRecord
  belongs_to :user
  belongs_to :question
end
