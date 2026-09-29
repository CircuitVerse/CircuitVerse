# frozen_string_literal: true

class GradingResult < ApplicationRecord
  belongs_to :project

  validates :suite_snapshot, presence: true
  validates :score, numericality: { in: 0..100 }, allow_nil: true
end
