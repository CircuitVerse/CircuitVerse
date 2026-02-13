# frozen_string_literal: true

class Submission < ApplicationRecord
  belongs_to :contest
  belongs_to :project
  belongs_to :user
  has_many :submission_votes, dependent: :destroy
  has_one :contest_winner, dependent: :destroy

  validates :project_id, uniqueness: { scope: :contest_id }

  validate :project_cannot_be_forked

  private

  def project_cannot_be_forked
    if project&.forked_project_id.present?
      errors.add(:project, "cannot be a forked project")
    end
  end
end
