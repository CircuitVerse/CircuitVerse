# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.
# frozen_string_literal: true

DependencyDetection.defer do
  named :bunny

  depends_on do
    defined?(Bunny)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Bunny instrumentation'
    require 'new_relic/agent/distributed_tracing/cross_app_tracing'
    require 'new_relic/agent/messaging'
    require 'new_relic/agent/transaction/message_broker_segment'
  end

  executes do
    module Bunny
      class Exchange
        alias_method :publish_without_new_relic, :publish

        def publish payload, opts = {}
          begin
            destination = NewRelic::Agent::Instrumentation::Bunny.exchange_name(name)

            tracing_enabled =
              NewRelic::Agent::CrossAppTracing.cross_app_enabled? ||
              NewRelic::Agent.config[:'distributed_tracing.enabled']
            opts[:headers] ||= {} if tracing_enabled

            segment = NewRelic::Agent::Messaging.start_amqp_publish_segment(
              library: NewRelic::Agent::Instrumentation::Bunny::LIBRARY,
              destination_name: destination,
              headers: opts[:headers],
              routing_key: opts[:routing_key] || opts[:key],
              reply_to: opts[:reply_to],
              correlation_id: opts[:correlation_id],
              exchange_type: type
            )
          rescue => e
            NewRelic::Agent.logger.error "Error starting message broker segment in Bunny::Exchange#publish", e
            publish_without_new_relic payload, opts
          else
            NewRelic::Agent::Tracer.capture_segment_error segment do
              publish_without_new_relic payload, opts
            end
          ensure
            segment.finish if segment
          end
        end
      end

      class Queue
        alias_method :pop_without_new_relic, :pop

        def pop(opts = {:manual_ack => false}, &block)
          bunny_error, delivery_info, message_properties, _payload = nil, nil, nil, nil
          begin
            t0 = Time.now
            msg = pop_without_new_relic opts, &block
            delivery_info, message_properties, _payload = msg
          rescue StandardError => error
            bunny_error = error
          end

          begin
            exchange_name, exchange_type = if delivery_info
              [ NewRelic::Agent::Instrumentation::Bunny.exchange_name(delivery_info.exchange),
                NewRelic::Agent::Instrumentation::Bunny.exchange_type(delivery_info, channel) ]
            else
              [ NewRelic::Agent::Instrumentation::Bunny.exchange_name(NewRelic::EMPTY_STR),
                NewRelic::Agent::Instrumentation::Bunny.exchange_type({}, channel) ]
            end

            segment = NewRelic::Agent::Messaging.start_amqp_consume_segment(
              library: NewRelic::Agent::Instrumentation::Bunny::LIBRARY,
              destination_name: exchange_name,
              delivery_info: (delivery_info || {}),
              message_properties: (message_properties || {headers: {}}),
              exchange_type: exchange_type,
              queue_name: name,
              start_time: t0
            )
          rescue => e
            NewRelic::Agent.logger.error "Error starting message broker segment in Bunny::Queue#pop", e
          else
            if bunny_error
              segment.notice_error bunny_error
              raise bunny_error
            end
          ensure
            segment.finish if segment
          end

          msg
        end

        alias_method :purge_without_new_relic, :purge

        if RUBY_VERSION < "2.7.0"
          def purge *args
            begin
              type = server_named? ? :temporary_queue : :queue
              segment = NewRelic::Agent::Tracer.start_message_broker_segment(
                action: :purge,
                library: NewRelic::Agent::Instrumentation::Bunny::LIBRARY,
                destination_type: type,
                destination_name: name
              )
            rescue => e
              NewRelic::Agent.logger.error "Error starting message broker segment in Bunny::Queue#purge", e
              purge_without_new_relic(*args)
            else
              NewRelic::Agent::Tracer.capture_segment_error segment do
                purge_without_new_relic(*args)
              end
            ensure
              segment.finish if segment
            end
          end

        else     
          def purge *args, **kwargs
            begin
              type = server_named? ? :temporary_queue : :queue
              segment = NewRelic::Agent::Tracer.start_message_broker_segment(
                action: :purge,
                library: NewRelic::Agent::Instrumentation::Bunny::LIBRARY,
                destination_type: type,
                destination_name: name
              )
            rescue => e
              NewRelic::Agent.logger.error "Error starting message broker segment in Bunny::Queue#purge", e
              purge_without_new_relic(*args, **kwargs)
            else
              NewRelic::Agent::Tracer.capture_segment_error segment do
                purge_without_new_relic(*args, **kwargs)
              end
            ensure
              segment.finish if segment
            end
          end
        end

      end

      class Consumer
        alias_method :call_without_new_relic, :call

        if RUBY_VERSION < "2.7.0"
          def call *args
            delivery_info, message_properties, _ = args
            queue_name = queue.respond_to?(:name) ? queue.name : queue
  
            NewRelic::Agent::Messaging.wrap_amqp_consume_transaction(
              library: NewRelic::Agent::Instrumentation::Bunny::LIBRARY,
              destination_name: NewRelic::Agent::Instrumentation::Bunny.exchange_name(delivery_info.exchange),
              delivery_info: delivery_info,
              message_properties: message_properties,
              exchange_type: NewRelic::Agent::Instrumentation::Bunny.exchange_type(delivery_info, channel),
              queue_name: queue_name) do
  
              call_without_new_relic(*args)
            end
          end
        else
          def call *args, **kwargs
            delivery_info, message_properties, _ = args
            queue_name = queue.respond_to?(:name) ? queue.name : queue

            NewRelic::Agent::Messaging.wrap_amqp_consume_transaction(
              library: NewRelic::Agent::Instrumentation::Bunny::LIBRARY,
              destination_name: NewRelic::Agent::Instrumentation::Bunny.exchange_name(delivery_info.exchange),
              delivery_info: delivery_info,
              message_properties: message_properties,
              exchange_type: NewRelic::Agent::Instrumentation::Bunny.exchange_type(delivery_info, channel),
              queue_name: queue_name) do

              call_without_new_relic(*args, **kwargs)
            end
          end
        end



      end
    end
  end
end

module NewRelic
  module Agent
    module Instrumentation
      module Bunny
        LIBRARY = 'RabbitMQ'
        DEFAULT_NAME = 'Default'
        DEFAULT_TYPE = :direct

        SLASH   = '/'

        class << self
          def exchange_name name
            name.empty? ? DEFAULT_NAME : name
          end

          def exchange_type delivery_info, channel
            if di_exchange = delivery_info[:exchange]
              return DEFAULT_TYPE if di_exchange.empty?
              return channel.exchanges[delivery_info[:exchange]].type if channel.exchanges[di_exchange]
            end
          end
        end
      end
    end
  end
end
