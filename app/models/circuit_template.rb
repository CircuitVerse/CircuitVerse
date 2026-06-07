# frozen_string_literal: true

class CircuitTemplate < ApplicationRecord
  belongs_to :created_by, class_name: "User"
  has_many   :assignments, dependent: :nullify
  has_many   :assignment_test_cases, through: :assignments

  validates :name,         presence: true
  validates :circuit_data, presence: true

  scope :public_templates, -> { where(public: true) }
  scope :by_user, ->(user) { where(created_by: user) }
end
