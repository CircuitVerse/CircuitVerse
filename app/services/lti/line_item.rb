# frozen_string_literal: true

module Lti
  class LineItem
    SCOPE = "https://purl.imsglobal.org/spec/lti-ags/scope/lineitem"
    CONTAINER_TYPE = "application/vnd.ims.lis.v2.lineitemcontainer+json"
    ITEM_TYPE = "application/vnd.ims.lis.v2.lineitem+json"
    TIMEOUT = 5

    class Error < StandardError; end

    class << self
      # Returns the URL of the gradebook column for this resource, creating one
      # only when the platform does not already hold it.
      def find_or_create(lineitems_url, access_token, resource_id:, label:, score_maximum:)
        existing(lineitems_url, access_token, resource_id) ||
          create(lineitems_url, access_token, resource_id, label, score_maximum)
      rescue HTTP::Error, JSON::ParserError, KeyError => e
        raise Error, e.message
      end

      private

        def existing(url, token, resource_id)
          items = parse(client(token, CONTAINER_TYPE).get(url, params: { resource_id: resource_id }))
          items.first["id"] if items.is_a?(Array) && items.any?
        end

        def create(url, token, resource_id, label, score_maximum)
          body = { scoreMaximum: score_maximum, label: label, resourceId: resource_id }
          response = client(token, ITEM_TYPE)
                     .headers("Content-Type" => ITEM_TYPE)
                     .post(url, body: body.to_json)
          parse(response).fetch("id")
        end

        def client(token, accept)
          HTTP.timeout(TIMEOUT).auth("Bearer #{token}").headers("Accept" => accept)
        end

        def parse(response)
          raise Error, "line item request failed: #{response.status}" unless response.status.success?

          JSON.parse(response.body.to_s)
        end
    end
  end
end
