# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/transaction/segment'
require 'new_relic/agent/distributed_tracing/cross_app_tracing'

module NewRelic
  module Agent
    class Transaction
      class MessageBrokerSegment < Segment
        CONSUME  = 'Consume'.freeze
        EXCHANGE = 'Exchange'.freeze
        NAMED    = 'Named/'.freeze
        PRODUCE  = 'Produce'.freeze
        QUEUE    = 'Queue'.freeze
        PURGE    = 'Purge'.freeze
        SLASH    = '/'.freeze
        TEMP     = 'Temp'.freeze
        TOPIC    = 'Topic'.freeze
        UNKNOWN  = 'Unknown'.freeze

        DESTINATION_TYPES = [
          :exchange,
          :queue,
          :topic,
          :temporary_queue,
          :temporary_topic,
          :unknown
        ]

        ACTIONS = {
          consume: CONSUME,
          produce: PRODUCE,
          purge: PURGE
        }

        TYPES = {
          exchange:        EXCHANGE,
          temporary_queue: QUEUE,
          queue:           QUEUE,
          temporary_topic: TOPIC,
          topic:           TOPIC,
          unknown:         EXCHANGE
        }

        METRIC_PREFIX = 'MessageBroker/'.freeze

        attr_reader :action,
                    :destination_name,
                    :destination_type,
                    :library,
                    :headers

        def initialize action: nil,
                       library: nil,
                       destination_type: nil,
                       destination_name: nil,
                       headers: nil,
                       parameters: nil,
                       start_time: nil

          # ruby 2.0.0 does not support required kwargs
          raise ArgumentError, 'missing required argument: action' if action.nil?
          raise ArgumentError, 'missing required argument: library' if library.nil?
          raise ArgumentError, 'missing required argument: destination_type' if destination_type.nil?
          raise ArgumentError, 'missing required argument: destination_name' if destination_name.nil?

          @action = action
          @library = library
          @destination_type = destination_type
          @destination_name = destination_name
          @headers = headers
          super(nil, nil, start_time)
          params.merge! parameters if parameters
        end

        def name
          return @name if @name
          @name = METRIC_PREFIX + library
          @name << SLASH << TYPES[destination_type] << SLASH << ACTIONS[action] << SLASH

          if destination_type == :temporary_queue || destination_type == :temporary_topic
            @name << TEMP
          else
            @name << NAMED << destination_name.to_s
          end

          @name
        end

        def transaction_assigned
          if headers && transaction && action == :produce && record_metrics?
            transaction.distributed_tracer.insert_distributed_trace_header headers
            transaction.distributed_tracer.insert_cat_headers headers
          end
        rescue => e
          NewRelic::Agent.logger.error "Error during message header processing", e
        end
      end
    end
  end
end
