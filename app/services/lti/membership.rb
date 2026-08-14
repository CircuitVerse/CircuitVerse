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
          members.concat(page_members(parse(response)))
          url = next_page(response, url, memberships_url)
          break if url.blank?
        end
        raise Error, "roster did not end within #{MAX_PAGES} pages" if url.present?

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

        # An empty roster is "members": []. A page without the list is a broken
        # response, and treating it as empty would tell a full-replace sync that
        # the whole class has left.
        def page_members(payload)
          members = payload["members"] if payload.is_a?(Hash)
          raise Error, "roster page carried no members list" unless members.is_a?(Array)

          members
        end

        # RFC 8288 allows the relation as a bare token or a quoted string, more
        # than one relation per link, other parameters alongside it, and a
        # relative target that has to be resolved against the page it came from.
        def next_page(response, current_url, origin_url)
          target = link_entries(response).find { |_target, params| relations(params).include?("next") }&.first
          return if target.blank?

          resolve_next(target, current_url, origin_url)
        end

        # A link we cannot follow must not read as the end of the roster, or a
        # full-replace sync treats the members we never fetched as departed.
        # The bearer token rides on every page, so a target that leaves the
        # platform's origin is refused rather than requested.
        def resolve_next(target, current_url, origin_url)
          resolved = URI.join(current_url, target)
          origin = URI.parse(origin_url)
          raise Error, "roster next link left the platform origin: #{resolved}" unless same_origin?(resolved, origin)

          resolved.to_s
        rescue URI::InvalidURIError, ArgumentError
          raise Error, "roster next link could not be resolved: #{target}"
        end

        def same_origin?(resolved, origin)
          resolved.scheme == origin.scheme && resolved.host == origin.host &&
            resolved.port == origin.port
        end

        # A parameter value may itself contain a comma, so entries are split on
        # the angle-bracketed target rather than on the separator.
        def link_entries(response)
          response.headers["Link"].to_s.scan(/<([^>]*)>([^<]*)/)
        end

        def relations(params)
          params[/;\s*rel\s*=\s*("[^"]*"|'[^']*'|[^;,\s]*)/i, 1].to_s.delete(%q("')).downcase.split
        end
    end
  end
end
