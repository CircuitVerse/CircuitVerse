# frozen_string_literal: true

class AssignmentDeadlineSubmissionJob < ApplicationJob
  queue_as :default

  def perform(assignment_id)
    assignment = Assignment.find_by(id: assignment_id)

    return if assignment.nil? || (assignment.status == "closed")

    assignment.with_lock do
      next if assignment.nil? || (assignment.status == "closed")

      if Time.zone.now - assignment.deadline >= -10 && (assignment.status == "open")
        assignment.freeze_submissions
        assignment.status = "closed"
        assignment.save!
      end
    end
  end
end
