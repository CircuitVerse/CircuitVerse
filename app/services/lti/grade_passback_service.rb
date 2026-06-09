# frozen_string_literal: true

module Lti
  class GradePassbackService
    def self.send_score(submission)
      assignment = submission.assignment
      return unless assignment.lti_integrated?

      lis_outcome_service_url = assignment.lis_outcome_service_url
      lis_result_sourced_id   = submission.project&.lis_result_sourced_id
      return if lis_outcome_service_url.blank? || lis_result_sourced_id.blank?

      Rails.logger.info("[LTI] GradePassbackService: sending score for submission #{submission.id}")
      LtiScoreSubmission.new(
        assignment:              assignment,
        lis_result_sourced_id:   lis_result_sourced_id,
        score:                   submission.score.to_f / 100,
        lis_outcome_service_url: lis_outcome_service_url
      ).call
    end
  end
end
