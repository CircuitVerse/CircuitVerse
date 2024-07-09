# frozen_string_literal: true

class Question < ApplicationRecord
  belongs_to :category, class_name: "QuestionCategory", foreign_key: "category_id", inverse_of: :questions
end

