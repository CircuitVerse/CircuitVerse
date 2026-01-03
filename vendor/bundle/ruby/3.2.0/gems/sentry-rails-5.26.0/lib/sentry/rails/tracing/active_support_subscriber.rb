# frozen_string_literal: true

require "sentry/rails/tracing/abstract_subscriber"

module Sentry
  module Rails
    module Tracing
      class ActiveSupportSubscriber < AbstractSubscriber
        READ_EVENT_NAMES = %w[
          cache_read.active_support
        ].freeze

        WRITE_EVENT_NAMES = %w[
          cache_write.active_support
          cache_increment.active_support
          cache_decrement.active_support
        ].freeze

        REMOVE_EVENT_NAMES = %w[
          cache_delete.active_support
        ].freeze

        FLUSH_EVENT_NAMES = %w[
          cache_prune.active_support
        ].freeze

        EVENT_NAMES = READ_EVENT_NAMES + WRITE_EVENT_NAMES + REMOVE_EVENT_NAMES + FLUSH_EVENT_NAMES

        SPAN_ORIGIN = "auto.cache.rails"

        def self.subscribe!
          subscribe_to_event(EVENT_NAMES) do |event_name, duration, payload|
            record_on_current_span(
              op: operation_name(event_name),
              origin: SPAN_ORIGIN,
              start_timestamp: payload[START_TIMESTAMP_NAME],
              description: payload[:store],
              duration: duration
            ) do |span|
              span.set_data("cache.key", [*payload[:key]].select { |key| Utils::EncodingHelper.valid_utf_8?(key) })
              span.set_data("cache.hit", payload[:hit] == true) # Handle nil case
            end
          end
        end

        def self.operation_name(event_name)
          case
          when READ_EVENT_NAMES.include?(event_name)
            "cache.get"
          when WRITE_EVENT_NAMES.include?(event_name)
            "cache.put"
          when REMOVE_EVENT_NAMES.include?(event_name)
            "cache.remove"
          when FLUSH_EVENT_NAMES.include?(event_name)
            "cache.flush"
          else
            "other"
          end
        end
      end
    end
  end
end
