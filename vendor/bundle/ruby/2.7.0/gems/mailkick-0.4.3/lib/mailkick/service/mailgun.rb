# https://github.com/mailgun/mailgun-ruby

module Mailkick
  class Service
    class Mailgun < Mailkick::Service
      def initialize(options = {})
        require "mailgun"
        mailgun_client = ::Mailgun::Client.new(options[:api_key] || ENV["MAILGUN_API_KEY"])
        domain = options[:domain] || ActionMailer::Base.smtp_settings[:domain]
        @mailgun_events = ::Mailgun::Events.new(mailgun_client, domain)
      end

      def opt_outs
        unsubscribes + spam_reports + bounces
      end

      def unsubscribes
        fetch(@mailgun_events.get(event: "unsubscribed"), "unsubscribe")
      end

      def spam_reports
        fetch(@mailgun_events.get(event: "complained"), "spam")
      end

      def bounces
        fetch(@mailgun_events.get(event: "failed"), "bounce")
      end

      def self.discoverable?
        !!(defined?(::Mailgun) && ENV["MAILGUN_API_KEY"])
      end

      protected

      def fetch(response, reason)
        response.to_h["items"].map do |record|
          {
            email: record["recipient"],
            time: ActiveSupport::TimeZone["UTC"].at(record["timestamp"]),
            reason: reason
          }
        end
      end
    end
  end
end
