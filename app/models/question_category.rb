# frozen_string_literal: true

class Question < ApplicationRecord
  belongs_to :category, class_name: "QuestionCategory", inverse_of: :questions
end

