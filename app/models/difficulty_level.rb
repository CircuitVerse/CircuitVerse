# frozen_string_literal: true

class DifficultyLevel < ApplicationRecord
  enum difficulty_level: {
    easy: 0,
    medium: 1,
    hard: 2
  }
end
