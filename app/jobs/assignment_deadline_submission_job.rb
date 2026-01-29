# frozen_string_literal: true

class AssignmentDeadlineSubmissionJob < ApplicationJob
  queue_as :default

  def perform(assignment_id)
    assignment = Assignment.find_by(id: assignment_id)

    return if assignment.nil? || assignment.status == "closed"

    should_process = false
    assignment.with_lock do
      if assignment.status == "open" && Time.zone.now - assignment.deadline >= -10
        assignment.status = "closed"
        assignment.save!
        should_process = true
      end
    end

    return unless should_process

    assignment.projects.where(project_submission: false).find_each(batch_size: 10) do |proj|
      process_project_fork(proj)
    rescue StandardError => e
      Rails.logger.error("Failed to fork project #{proj.id}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))

    end
  end

  private

  def process_project_fork(proj)
    ActiveRecord::Base.transaction do
      submission = proj.fork(proj.author)
      submission.project_submission = true
      submission.save!

      proj.assignment_id = nil
      proj.save!
    end
  end
end
