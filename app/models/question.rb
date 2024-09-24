# frozen_string_literal: true

class Question < ApplicationRecord
  belongs_to :category, class_name: "QuestionCategory"
  enum difficulty_level: { easy: 0, medium: 1, hard: 2, expert: 3 }
  has_many :question_submission_histories, dependent: :destroy
end
