# frozen_string_literal: true

module Lti
  class GradePassbackService
    def self.send_score(submission)
      assignment = submission.assignment
      return unless assignment.lti_enabled?

      if assignment.lti_v1_3?
        send_ags_score(submission)
      else
        LtiScoreSubmission.new(
          assignment:              assignment,
          lis_result_sourced_id:   submission.project.lis_result_sourced_id,
          score:                   submission.verification_score,
          lis_outcome_service_url: assignment.lis_outcome_service_url
        ).call
      end
    end

    private

    def self.send_ags_score(submission)
      deployment   = submission.assignment.lti_deployment
      access_token = obtain_access_token(deployment)
      lineitem_url = submission.assignment.canvas_assignment_id

      response = Faraday.post("#{lineitem_url}/scores") do |req|
        req.headers["Authorization"] = "Bearer #{access_token}"
        req.headers["Content-Type"]  = "application/vnd.ims.lis.v1.score+json"
        req.body = {
          userId:           submission.user.lti_user_id,
          scoreGiven:       (submission.verification_score * 100).round(2),
          scoreMaximum:     100,
          activityProgress: "Submitted",
          gradingProgress:  "FullyGraded",
          timestamp:        Time.current.iso8601
        }.to_json
      end

      raise "AGS passback failed: #{response.status}" unless response.success?
    end

    def self.obtain_access_token(deployment)
      assertion = JWT.encode(
        {
          iss: deployment.client_id,
          sub: deployment.client_id,
          aud: deployment.access_token_url,
          iat: Time.current.to_i,
          exp: 5.minutes.from_now.to_i,
          jti: SecureRandom.uuid
        },
        Lti::KeyManager.private_key,
        "RS256"
      )

      response = Faraday.post(deployment.access_token_url,
        grant_type:            "client_credentials",
        client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
        client_assertion:      assertion,
        scope:                 "https://purl.imsglobal.org/spec/lti-ags/scope/score"
      )

      JSON.parse(response.body)["access_token"]
    end
  end
end
