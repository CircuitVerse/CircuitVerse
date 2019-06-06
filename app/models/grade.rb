# frozen_string_literal: true

class Grade < ApplicationRecord
  belongs_to :project
  belongs_to :grader, class_name: "User", foreign_key: :user_id
  belongs_to :assignment

  validates :grade, :user_id, :project_id, :assignment_id, presence: true
  validate :grading_scale, :assignment_project

  private
    def grading_scale
      valid = case assignment&.grading_scale
              when "no_scale"
                false
              when "letter"
                grade&.match(/^(A|B|C|D|E|F)$/).present?
              when "percent"
                grade&.match(/^[0-9][0-9]?$|^100$/).present?
      end

      errors.add(:grade, "Grade does not match scale or assignment cannot be graded") unless valid
    end

    def assignment_project
      if project&.assignment_id != assignment&.id
        errors.add(:project, "is not a part of the assignment")
      end
    end

    def self.to_csv(assignment_id)
      attributes = %w[email name grade]
      group_members = User.where(id: GroupMember.where(group_id:
        Assignment.find_by(id: assignment_id)&.group_id).pluck(:user_id))
      submissions = Project.where(assignment_id: assignment_id)&.includes(:grade, :author)

      CSV.generate(headers: true) do |csv|
        csv << attributes

        group_members.each do |member|
          submission = submissions.find { |s| (s.author_id == member.id &&
            s.assignment_id == assignment_id)}
          grade = submission&.grade&.grade
          grade = grade.present? ? grade : "N.A"
          csv << [member.email, member.name, grade]
        end
      end
    end
end
