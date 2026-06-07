# frozen_string_literal: true

class CircuitVerificationJob < ApplicationJob
  queue_as :verification

  def perform(submission_id)
    submission = AssignmentSubmission.find(submission_id)
    result = CircuitVerificationService.new(
      submission.assignment,
      submission.project
    ).verify!

    submission.update!(
      score:  result.score,
      status: result.passed ? :graded : :submitted
    )

    if result.passed && submission.assignment.lti_enabled?
      Lti::GradePassbackService.send_score(submission)
    end
  end
end
