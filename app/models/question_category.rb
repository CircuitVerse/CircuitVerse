class QuestionCategory < ApplicationRecord
  has_many :questions, foreign_key: "category_id", dependent: :destroy
end