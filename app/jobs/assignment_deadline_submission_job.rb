# frozen_string_literal: true

class AssignmentDeadlineSubmissionJob < ApplicationJob
  queue_as :default

  retry_on ActiveRecord::LockWaitTimeout, ActiveRecord::QueryCanceled, wait: 1.second, attempts: 4

  def perform(assignment_id)
    assignment = Assignment.find_by(id: assignment_id)
    return if assignment.nil? || assignment.status == "closed"

    project_ids = []
    should_close = false

    # Call the helper here
    with_lock_retries(assignment.id) do |a|
      next if a.status == "closed"

      if (Time.zone.now - a.deadline) >= -10 && a.status == "open"
        project_ids = a.projects.where(project_submission: false).pluck(:id)
        a.update!(status: "closed")
        should_close = true
      end
    end

    return unless should_close
    return if project_ids.empty?

    # Heavy work outside the transaction
    Project.where(id: project_ids).find_each(batch_size: 100) do |proj|
      next if proj.project_submission

      submission = proj.fork(proj.author)
      submission.project_submission = true
      proj.assignment_id = nil
      proj.save!
      submission.save!
    end
  end

  # 👇 Put the helper here — inside the same class
  private

  def with_lock_retries(assignment_id, tries: 4, base_sleep: 0.25)
    attempt = 0
    begin
      Assignment.transaction do
        ActiveRecord::Base.connection.execute("SET LOCAL lock_timeout = '800ms'")
        a = Assignment.lock("FOR UPDATE").find(assignment_id)
        yield a
      end
    rescue ActiveRecord::LockWaitTimeout, ActiveRecord::QueryCanceled
      attempt += 1
      if attempt <= tries
        sleep(base_sleep * attempt + rand * 0.1)
        retry
      else
        Rails.logger.warn("[AssignmentDeadlineSubmissionJob] lock timeout id=#{assignment_id} after #{attempt} tries")
        raise
      end
    end
  end
end
