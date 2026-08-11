# frozen_string_literal: true

module Lti
  class Membership
    SCOPE = "https://purl.imsglobal.org/spec/lti-nrps/scope/contextmembership.readonly"
    MEDIA_TYPE = "application/vnd.ims.lti-nrps.v2.membershipcontainer+json"
    LEARNER = "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner"
    INSTRUCTOR = "http://purl.imsglobal.org/vocab/lis/v2/membership#Instructor"
    TIMEOUT = 5
    MAX_PAGES = 50

    class Error < StandardError; end

    class << self
      # Returns every member the platform reports, inactive ones included, since
      # a roster sync has to see who left as well as who is there.
      def fetch(memberships_url, access_token)
        members = []
        url = memberships_url

        MAX_PAGES.times do
          response = request(url, access_token)
          members.concat(Array(parse(response)["members"]))
          url = next_page(response)
          break if url.blank?
        end

        members
      rescue HTTP::Error, JSON::ParserError => e
        raise Error, e.message
      end

      private

        def request(url, token)
          HTTP.timeout(TIMEOUT).auth("Bearer #{token}").headers("Accept" => MEDIA_TYPE).get(url)
        end

        def parse(response)
          raise Error, "membership request failed: #{response.status}" unless response.status.success?

          JSON.parse(response.body.to_s)
        end

        def next_page(response)
          response.headers["Link"].to_s[/<([^>]+)>\s*;\s*rel="next"/, 1]
        end
    end
  end
end
