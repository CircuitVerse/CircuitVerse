# frozen_string_literal: true

class AssignmentDeadlineSubmissionJob < ApplicationJob
  queue_as :default

  # Closes the assignment and snapshots student submissions if the deadline has passed.
  def perform(assignment_id)
    assignment = Assignment.find_by(id: assignment_id)

    return if assignment.nil? || (assignment.status == "closed")

    assignment.with_lock do
      next unless Time.zone.now - assignment.deadline >= -10

      assignment.close!(deadline: assignment.deadline)
    end
  end
end
