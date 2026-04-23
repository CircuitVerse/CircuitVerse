# frozen_string_literal: true

class Submission < ApplicationRecord
  belongs_to :contest
  belongs_to :project
  belongs_to :user
  has_many :submission_votes, dependent: :destroy
  has_one :contest_winner, dependent: :destroy
end
