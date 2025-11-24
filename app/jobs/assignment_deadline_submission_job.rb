# frozen_string_literal: true

class AssignmentDeadlineSubmissionJob < ApplicationJob
  queue_as :default

  # Re-enqueue on transient DB lock errors
  retry_on ActiveRecord::LockWaitTimeout, ActiveRecord::QueryCanceled, wait: 1.second, attempts: 4

  def perform(assignment_id)
    assignment = Assignment.find_by(id: assignment_id)
    return unless assignment

    project_ids = []
    deadline_met = false

    # 1) Under a short lock: snapshot remaining work and note deadline condition
    with_lock_retries(assignment.id) do |a|
      project_ids  = a.projects.where(project_submission: false).pluck(:id)
      deadline_met = (Time.zone.now - a.deadline) >= -10
    end

    # 2) Heavy work OUTSIDE the assignment lock (idempotent + concurrency-safe)
    if project_ids.any?
      Project.where(id: project_ids).find_each(batch_size: 100) do |stub|
        Project.transaction do
          # Take a per-row lock and re-check current DB state
          p = Project.lock.find_by(id: stub.id)
          next unless p && p.assignment_id == assignment.id && !p.project_submission

          submission = p.fork(p.author)
          submission.project_submission = true

          p.assignment_id = nil
          p.save!
          submission.save!
        end
      end
    end

    # 3) Finalize: if deadline holds and nothing remains, close idempotently
    with_lock_retries(assignment.id) do |a|
      still_remaining = a.projects.where(project_submission: false).exists?
      a.update!(status: "closed") if deadline_met && !still_remaining && a.status != "closed"
    end
  end

  private

  # Fail fast on row locks with bounded attempts (tries = max attempts)
  def with_lock_retries(assignment_id, tries: 4, base_sleep: 0.25, lock_ms: 800)
    lock_ms = Integer(lock_ms)
    raise ArgumentError, "lock_ms must be a positive integer" unless lock_ms.positive?

    attempts = 0
    begin
      attempts += 1
      Assignment.transaction do
        Assignment.connection.execute("SET LOCAL lock_timeout = '#{lock_ms}ms'")
        a = Assignment.lock("FOR UPDATE").find(assignment_id)
        yield a
      end
    rescue ActiveRecord::LockWaitTimeout, ActiveRecord::QueryCanceled => e
      if attempts < tries
        sleep(base_sleep * attempts + rand * 0.1) # backoff + jitter
        retry
      else
        Rails.logger.warn(
          "[AssignmentDeadlineSubmissionJob] lock timeout id=#{assignment_id} "\
          "after #{attempts} attempt#{'s' if attempts != 1} (last error: #{e.class})"
        )
        raise
      end
    end
  end
end
