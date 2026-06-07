# frozen_string_literal: true

module Lti
  class GradePassbackJob < ApplicationJob
    queue_as :default

    def perform(submission_id)
      submission = AssignmentSubmission
                     .includes(:assignment, :project, :user)
                     .find(submission_id)
      Lti::GradePassbackService.send_score(submission)
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error("[LTI] GradePassbackJob submission not found: #{e.message}")
    rescue StandardError => e
      Rails.logger.error("[LTI] GradePassbackJob failed: #{e.class} #{e.message}")
      raise
    end
  end
end
