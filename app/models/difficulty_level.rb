class DifficultyLevel < ApplicationRecord
  has_many :questions, dependent: :destroy
end
