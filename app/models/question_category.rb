# frozen_string_literal: true

class QuestionCategory < ApplicationRecord
  has_many :questions, foreign_key: "category_id"
end
