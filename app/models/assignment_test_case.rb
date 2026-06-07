# frozen_string_literal: true

class AssignmentTestCase < ApplicationRecord
  belongs_to :assignment

  validates :description,     presence: true
  validates :input_pins,      presence: true
  validates :expected_output, presence: true
  validates :position,        numericality: { greater_than_or_equal_to: 0 }

  default_scope { order(position: :asc) }

  def pass?(actual_output)
    actual_output.to_h == expected_output.to_h
  end
end
