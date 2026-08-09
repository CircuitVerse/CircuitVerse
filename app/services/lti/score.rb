# frozen_string_literal: true

module Lti
  class Score
    SCOPE = "https://purl.imsglobal.org/spec/lti-ags/scope/score"
    MEDIA_TYPE = "application/vnd.ims.lis.v1.score+json"
    TIMEOUT = 5

    class Error < StandardError; end

    class << self
      def publish(lineitem_url, access_token, user_id:, score_given:, score_maximum:)
        response = HTTP.timeout(TIMEOUT)
                       .auth("Bearer #{access_token}")
                       .headers("Content-Type" => MEDIA_TYPE)
                       .post(scores_url(lineitem_url),
                             body: body(user_id, score_given, score_maximum).to_json)
        raise Error, "score request failed: #{response.status}" unless response.status.success?

        true
      rescue HTTP::Error, URI::InvalidURIError => e
        raise Error, e.message
      end

      private

        # /scores goes on the line item path, leaving any query the platform put
        # on the line item url intact.
        def scores_url(lineitem_url)
          uri = URI.parse(lineitem_url)
          uri.path = "#{uri.path}/scores"
          uri.to_s
        end

        def body(user_id, given, maximum)
          { userId: user_id, scoreGiven: given, scoreMaximum: maximum,
            timestamp: Time.current.utc.iso8601(3),
            activityProgress: "Completed", gradingProgress: "FullyGraded" }
        end
    end
  end
end
