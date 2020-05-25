# frozen_string_literal: true

class Grade < ApplicationRecord
  LETTER_MATCH = /^(A|B|C|D|E|F)$/.freeze
  PERCENT_MATCH = /^[0-9][0-9]?$|^100$/.freeze

  belongs_to :project
  belongs_to :grader, class_name: "User", foreign_key: :user_id
  belongs_to :assignment

  validates :grade, :user_id, :project_id, :assignment_id, presence: true
  validate :grading_scale, :assignment_project

  private

    def grading_scale
      valid = case assignment.grading_scale
              when "no_scale"
                false
              when "letter"
                grade&.match(LETTER_MATCH).present?
              when "percent"
                grade&.match(PERCENT_MATCH).present?
              when "custom"
                true
      end

      errors.add(:grade, "Grade does not match scale or assignment cannot be graded") unless valid
    end

    def assignment_project
      if project&.assignment_id != assignment&.id
        errors.add(:project, "is not a part of the assignment")
      end
    end

    def self.to_csv(assignment_id)
      attributes = %w[email name grade remarks]
      group_members = User.joins(group_members: :assignments)
                          .where(group_members: { assignments: { id: assignment_id } })
      submissions = Project.where(assignment_id: assignment_id)&.includes(:grade, :author)

      CSV.generate(headers: true) do |csv|
        csv << attributes

        group_members.each do |member|
          submission = submissions.find do |s| (

                         
                         s.author_id == member.id &&
            s.assignment_id == assignment_id)
          end
          grade = submission&.grade&.grade
          remarks = submission&.grade&.remarks
          grade = grade.presence || "N.A"
          remarks = remarks.presence || "N.A"
          csv << [member.email, member.name, grade, remarks]
        end
      end
    end
end
