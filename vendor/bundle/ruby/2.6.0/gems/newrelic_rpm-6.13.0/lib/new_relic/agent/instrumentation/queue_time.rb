# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  module Agent
    module Instrumentation
      # https://newrelic.com/docs/features/tracking-front-end-time
      # Record queue time metrics based on any of three headers
      # which can be set on the request.
      module QueueTime
        REQUEST_START_HEADER    = 'HTTP_X_REQUEST_START'.freeze
        QUEUE_START_HEADER      = 'HTTP_X_QUEUE_START'.freeze
        MIDDLEWARE_START_HEADER = 'HTTP_X_MIDDLEWARE_START'.freeze
        ALL_QUEUE_METRIC        = 'WebFrontend/QueueTime'.freeze
        # any timestamps before this are thrown out and the parser
        # will try again with a larger unit (2000/1/1 UTC)
        EARLIEST_ACCEPTABLE_TIME = Time.at(946684800)

        CANDIDATE_HEADERS = [
          REQUEST_START_HEADER,
          QUEUE_START_HEADER,
          MIDDLEWARE_START_HEADER
        ].freeze

        DIVISORS = [1_000_000, 1_000, 1]

        module_function

        def parse_frontend_timestamp(headers, now=Time.now)
          earliest = nil

          CANDIDATE_HEADERS.each do |header|
            if headers[header]
              parsed = parse_timestamp(timestamp_string_from_header_value(headers[header]))
              if parsed && (!earliest || parsed < earliest)
                earliest = parsed
              end
            end
          end

          if earliest && earliest > now
            NewRelic::Agent.logger.debug("Negative queue time detected, treating as zero: start=#{earliest.to_f} > now=#{now.to_f}")
            earliest = now
          end

          earliest
        end

        def timestamp_string_from_header_value(value)
          case value
          when /^\s*([\d+\.]+)\s*$/ then $1
          # following regexp intentionally unanchored to handle
          # (ie ignore) leading server names
          when /t=([\d+\.]+)/       then $1
          end
        end

        def parse_timestamp(string)
          DIVISORS.each do |divisor|
            begin
              t = Time.at(string.to_f / divisor)
              return t if t > EARLIEST_ACCEPTABLE_TIME
            rescue RangeError
              # On Ruby versions built with a 32-bit time_t, attempting to
              # instantiate a Time object in the far future raises a RangeError,
              # in which case we know we've chosen the wrong divisor.
            end
          end

          nil
        end
      end
    end
  end
end
