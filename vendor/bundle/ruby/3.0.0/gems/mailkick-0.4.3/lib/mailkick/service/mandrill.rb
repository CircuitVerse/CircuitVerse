# https://mandrillapp.com/api/docs/index.ruby.html

module Mailkick
  class Service
    class Mandrill < Mailkick::Service
      REASONS_MAP = {
        "hard-bounce" => "bounce",
        "soft-bounce" => "bounce",
        "spam" => "spam",
        "unsub" => "unsubscribe"
      }

      # TODO remove ENV["MANDRILL_APIKEY"]
      def initialize(options = {})
        require "mandrill"
        @mandrill = ::Mandrill::API.new(
          options[:api_key] || ENV["MANDRILL_APIKEY"] || ENV["MANDRILL_API_KEY"]
        )
      end

      # TODO paginate
      def opt_outs
        @mandrill.rejects.list.map do |record|
          {
            email: record["email"],
            time: ActiveSupport::TimeZone["UTC"].parse(record["created_at"]),
            reason: REASONS_MAP[record["reason"]]
          }
        end
      end

      # TODO remove ENV["MANDRILL_APIKEY"]
      def self.discoverable?
        !!(defined?(::Mandrill::API) && (ENV["MANDRILL_APIKEY"] || ENV["MANDRILL_API_KEY"]))
      end
    end
  end
end
