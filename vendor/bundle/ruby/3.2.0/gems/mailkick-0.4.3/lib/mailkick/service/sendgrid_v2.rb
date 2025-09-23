# https://github.com/sendgrid/sendgrid-ruby

module Mailkick
  class Service
    class SendGridV2 < Mailkick::Service
      def initialize(options = {})
        @api_key = options[:api_key] || ENV["SENDGRID_API_KEY"]
      end

      def opt_outs
        unsubscribes + spam_reports + bounces
      end

      def unsubscribes
        fetch(client.suppression.unsubscribes, "unsubscribe")
      end

      def spam_reports
        fetch(client.suppression.spam_reports, "spam")
      end

      def bounces
        fetch(client.suppression.bounces, "bounce")
      end

      def self.discoverable?
        !!(defined?(::SendGrid::API) && ENV["SENDGRID_API_KEY"])
      end

      protected

      def client
        @client ||= ::SendGrid::API.new(api_key: @api_key).client
      end

      def fetch(query, reason)
        # TODO paginate
        response = query.get

        raise "Bad status code: #{response.status_code}" if response.status_code.to_i != 200

        response.parsed_body.map do |record|
          {
            email: record[:email],
            time: Time.at(record[:created]),
            reason: reason
          }
        end
      end
    end
  end
end
