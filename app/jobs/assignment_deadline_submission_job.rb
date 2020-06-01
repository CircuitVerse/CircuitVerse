# frozen_string_literal: true

class AssignmentDeadlineSubmissionJob < ApplicationJob
  queue_as :default

  def perform(assignment_id)
    assignment = Assignment.find_by(id: assignment_id)

    return if assignment.nil? || (assignment.status == "closed")

    assignment.with_lock do
      return if assignment.nil? || (assignment.status == "closed")

      if Time.zone.now - assignment.deadline >= -10

        if assignment.status == "open"
          assignment.projects.each do |proj|
            next unless proj.project_submission == false

            submission = proj.dup
            submission.project_submission = true
            submission.forked_project_id = proj.id
            proj.assignment_id = nil
            proj.save!
            submission.save!
          end
          assignment.status = "closed"
          assignment.save!
        end

      end
    end
  end
end
