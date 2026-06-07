# frozen_string_literal: true

class AssignmentSubmission < ApplicationRecord
  belongs_to :assignment
  belongs_to :project
  belongs_to :user
  belongs_to :subgroup, optional: true

  enum :status, {
    draft:     0,
    submitted: 1,
    graded:    2
  }, prefix: true

  validates :project_id, uniqueness: { scope: :assignment_id }
  validate  :subgroup_required_for_group_submission

  def verification_score
    return 0.0 if score.nil?

    (score / 100.0).clamp(0.0, 1.0)
  end

  private

  def subgroup_required_for_group_submission
    if assignment&.submission_type == "group" && subgroup_id.nil?
      errors.add(:subgroup, "required for group assignments")
    end
  end
end
