# https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SESV2/Client.html

module Mailkick
  class Service
    class AwsSes < Mailkick::Service
      REASONS_MAP = {
        "BOUNCE" => "bounce",
        "COMPLAINT" => "spam"
      }

      def initialize(options = {})
        @options = options
      end

      def opt_outs
        response = client.list_suppressed_destinations({
          reasons: ["BOUNCE", "COMPLAINT"],
          # TODO make configurable
          start_date: Time.now - (86400 * 365),
          end_date: Time.now
        })

        opt_outs = []
        response.each do |page|
          page.suppressed_destination_summaries.each do |record|
            opt_outs << {
              email: record.email_address,
              time: record.last_update_time,
              reason: REASONS_MAP[record.reason]
            }
          end
        end
        opt_outs
      end

      def self.discoverable?
        !!defined?(::Aws::SESV2::Client)
      end

      private

      def client
        @client ||= ::Aws::SESV2::Client.new
      end
    end
  end
end
