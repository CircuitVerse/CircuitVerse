module Bugsnag
  # @api private
  class EndpointValidator
    def self.validate(endpoints)
      # ensure we have an EndpointConfiguration object
      return Result.missing_urls unless endpoints.is_a?(EndpointConfiguration)

      # check for missing URLs
      return Result.missing_urls if endpoints.notify.nil? && endpoints.sessions.nil?
      return Result.missing_notify if endpoints.notify.nil?
      return Result.missing_session if endpoints.sessions.nil?

      # check for empty URLs
      return Result.invalid_urls if endpoints.notify.empty? && endpoints.sessions.empty?
      return Result.invalid_notify if endpoints.notify.empty?
      return Result.invalid_session if endpoints.sessions.empty?

      Result.valid
    end

    # @api private
    class Result
      # rubocop:disable Layout/LineLength
      MISSING_URLS = "Invalid configuration. endpoints must be set with both a notify and session URL. Bugsnag will not send any requests.".freeze
      MISSING_NOTIFY_URL = "Invalid configuration. endpoints.sessions cannot be set without also setting endpoints.notify. Bugsnag will not send any requests.".freeze
      MISSING_SESSION_URL = "Invalid configuration. endpoints.notify cannot be set without also setting endpoints.sessions. Bugsnag will not send any sessions.".freeze

      INVALID_URLS = "Invalid configuration. endpoints should be valid URLs, got empty strings. Bugsnag will not send any requests.".freeze
      INVALID_NOTIFY_URL = "Invalid configuration. endpoints.notify should be a valid URL, got empty string. Bugsnag will not send any requests.".freeze
      INVALID_SESSION_URL = "Invalid configuration. endpoints.sessions should be a valid URL, got empty string. Bugsnag will not send any sessions.".freeze
      # rubocop:enable Layout/LineLength

      attr_reader :reason

      def initialize(valid, keep_events_enabled_for_backwards_compatibility = true, reason = nil)
        @valid = valid
        @keep_events_enabled_for_backwards_compatibility = keep_events_enabled_for_backwards_compatibility
        @reason = reason
      end

      def valid?
        @valid
      end

      def keep_events_enabled_for_backwards_compatibility?
        @keep_events_enabled_for_backwards_compatibility
      end

      # factory functions

      def self.valid
        new(true)
      end

      def self.missing_urls
        new(false, false, MISSING_URLS)
      end

      def self.missing_notify
        new(false, false, MISSING_NOTIFY_URL)
      end

      def self.missing_session
        new(false, true, MISSING_SESSION_URL)
      end

      def self.invalid_urls
        new(false, false, INVALID_URLS)
      end

      def self.invalid_notify
        new(false, false, INVALID_NOTIFY_URL)
      end

      def self.invalid_session
        new(false, true, INVALID_SESSION_URL)
      end
    end
  end
end
