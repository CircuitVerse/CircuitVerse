# frozen_string_literal: true

module Sentry
  # @api private
  class Envelope::Item
    STACKTRACE_FRAME_LIMIT_ON_OVERSIZED_PAYLOAD = 500
    MAX_SERIALIZED_PAYLOAD_SIZE = 1024 * 1000

    SIZE_LIMITS = Hash.new(MAX_SERIALIZED_PAYLOAD_SIZE).update(
      "profile" => 1024 * 1000 * 50
    )

    attr_reader :size_limit, :headers, :payload, :type, :data_category

    # rate limits and client reports use the data_category rather than envelope item type
    def self.data_category(type)
      case type
      when "session", "attachment", "transaction", "profile", "span", "log" then type
      when "sessions" then "session"
      when "check_in" then "monitor"
      when "statsd", "metric_meta" then "metric_bucket"
      when "event" then "error"
      when "client_report" then "internal"
      else "default"
      end
    end

    def initialize(headers, payload)
      @headers = headers
      @payload = payload
      @type = headers[:type] || "event"
      @data_category = self.class.data_category(type)
      @size_limit = SIZE_LIMITS[type]
    end

    def to_s
      [JSON.generate(@headers), @payload.is_a?(String) ? @payload : JSON.generate(@payload)].join("\n")
    end

    def serialize
      result = to_s

      if result.bytesize > size_limit
        remove_breadcrumbs!
        result = to_s
      end

      if result.bytesize > size_limit
        reduce_stacktrace!
        result = to_s
      end

      [result, result.bytesize > size_limit]
    end

    def size_breakdown
      payload.map do |key, value|
        "#{key}: #{JSON.generate(value).bytesize}"
      end.join(", ")
    end

    private

    def remove_breadcrumbs!
      if payload.key?(:breadcrumbs)
        payload.delete(:breadcrumbs)
      elsif payload.key?("breadcrumbs")
        payload.delete("breadcrumbs")
      end
    end

    def reduce_stacktrace!
      if exceptions = payload.dig(:exception, :values) || payload.dig("exception", "values")
        exceptions.each do |exception|
          # in most cases there is only one exception (2 or 3 when have multiple causes), so we won't loop through this double condition much
          traces = exception.dig(:stacktrace, :frames) || exception.dig("stacktrace", "frames")

          if traces && traces.size > STACKTRACE_FRAME_LIMIT_ON_OVERSIZED_PAYLOAD
            size_on_both_ends = STACKTRACE_FRAME_LIMIT_ON_OVERSIZED_PAYLOAD / 2
            traces.replace(
              traces[0..(size_on_both_ends - 1)] + traces[-size_on_both_ends..-1],
            )
          end
        end
      end
    end
  end
end
