# frozen_string_literal: true

class AssignmentDeadlineSubmissionJob < ApplicationJob
  queue_as :default

  # @param [Integer] assignment_id
  # @return [void]
  def perform(assignment_id)
    # @type [Assignment]
    assignment = Assignment.find_by(id: assignment_id)

    return if assignment.nil? || (assignment.status == "closed")

    assignment.with_lock do
      next if assignment.nil? || (assignment.status == "closed")

      if Time.zone.now - assignment.deadline >= -10 && (assignment.status == "open")
        assignment.projects.each do |proj|
          next unless proj.project_submission == false

          submission = proj.fork(proj.author)
          submission.project_submission = true
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
