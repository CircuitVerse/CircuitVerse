# frozen_string_literal: true

class AssignmentDeadlineSubmissionJob < ApplicationJob
  queue_as :default

  def perform(assignment_id)
    assignment = Assignment.find_by(id: assignment_id)

    return if assignment.nil? || (assignment.status == "closed")

    assignment.with_lock do
      next if assignment.nil? || (assignment.status == "closed")

      if Time.zone.now - assignment.deadline >= -10 && (assignment.status == "open")
        assignment.projects.each do |proj|
          next unless proj.project_submission == false

          begin
            submission = proj.fork(proj.author)
            submission.project_submission = true
            proj.assignment_id = nil
            proj.save!
            submission.save!
          rescue StandardError => e
            Rails.logger.error(
              "DeadlineSubmissionJob: failed to fork project #{proj.id} for assignment #{assignment_id}: #{e.message}"
            )
          end
        end
        assignment.status = "closed"
        assignment.save!
      end
    end
  end
end
