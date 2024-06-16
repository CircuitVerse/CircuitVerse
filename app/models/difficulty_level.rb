# frozen_string_literal: true

class DifficultyLevel < ApplicationRecord
  enum value: { easy: 0, medium: 1, hard: 2 }

  validates :name, presence: true
  validates :value, presence: true
end
