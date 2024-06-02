# frozen_string_literal: true

class DifficultyLevel < ApplicationRecord
  has_many :questions, dependent: :destroy
end
