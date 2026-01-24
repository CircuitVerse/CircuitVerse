# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :reporter, class_name: "User"
  belongs_to :reported_user, class_name: "User"
  validates :reason, presence: true
  validates :status, presence: true
end
