# frozen_string_literal: true

class AssignmentDeadlineSubmissionJob < ApplicationJob
  queue_as :default

  def perform(assignment_id)
    assignment = Assignment.find_by(id: assignment_id)
    @student_submission = 0

    return if assignment.nil? || (assignment.status == "closed")

    assignment.with_lock do
      return if assignment.nil? || (assignment.status == "closed")

      if Time.zone.now - assignment.deadline >= -10

        if assignment.status == "open"
          assignment.projects.each do |proj|
            next unless proj.project_submission == false

            submission = proj.fork(proj.author)
            submission.project_submission = true
            proj.assignment_id = nil
            @student_submission += 1
            proj.save!
            submission.save!
          end
          assignment.status = "closed"
          assignment.save!
          AssignmentMailer.deadline_assignment_email(assignment, @student_submission).deliver_later
        end

      end
    end
  end
end
