# frozen_string_literal: true

module Lti
  class GradePassbackJob < ApplicationJob
    queue_as :default

    def perform(submission_id)
      Rails.logger.info("[LTI] GradePassbackJob: starting for submission #{submission_id}")
      submission = AssignmentSubmission.includes(:assignment, :project, :user).find(submission_id)
      Lti::GradePassbackService.send_score(submission)
      Rails.logger.info("[LTI] GradePassbackJob: completed for submission #{submission_id}")
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn("[LTI] GradePassbackJob: submission #{submission_id} not found, skipping")
    rescue => e
      Rails.logger.error("[LTI] GradePassbackJob failed: #{e.class} — #{e.message}")
      raise
    end
  end
end
