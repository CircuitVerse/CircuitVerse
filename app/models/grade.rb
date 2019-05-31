# frozen_string_literal: true

class Grade < ApplicationRecord
  belongs_to :project, dependent: :destroy
  belongs_to :grader, class_name: "User", foreign_key: :user_id
  belongs_to :assignment, dependent: :destroy

  validate :grading_scale, :assignment_project

  private
    def grading_scale
      valid = case assignment.grading_scale
              when "no_scale"
                false
              when "letter"
                grade.match(/^(A|B|C|D|E|F)$/).present?
              when "percent"
                grade.match(/^[0-9][0-9]?$|^100$/).present?
      end

      errors.add(:grade, "Grade does not match scale or assignment cannot be graded") unless valid
    end

    def assignment_project
      if project.assignment_id != assignment.id
        errors.add(:project, "Project is not a part of the assignment")
      end
    end
end
