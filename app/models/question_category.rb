# frozen_string_literal: true

class QuestionCategory < ApplicationRecord
  belongs_to :category, class_name: "QuestionCategory", inverse_of: :questions
end

