# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/datastores'
require 'new_relic/agent/datastores/redis'

module NewRelic
  module Agent
    module Instrumentation
      module Redis
        extend self

        UNKNOWN = "unknown".freeze
        LOCALHOST = "localhost".freeze

        def host_for(client)
          client.path ? LOCALHOST : client.host
        rescue => e
          NewRelic::Agent.logger.debug "Failed to retrieve Redis host: #{e}"
          UNKNOWN
        end

        def port_path_or_id_for(client)
          client.path || client.port
        rescue => e
          NewRelic::Agent.logger.debug "Failed to retrieve Redis port_path_or_id: #{e}"
          UNKNOWN
        end
      end
    end
  end
end

DependencyDetection.defer do
  # Why not :redis? newrelic-redis used that name, so avoid conflicting
  named :redis_instrumentation

  depends_on do
    defined? ::Redis
  end

  depends_on do
    NewRelic::Agent.config[:disable_redis] == false
  end

  depends_on do
    NewRelic::Agent::Datastores::Redis.is_supported_version? &&
      NewRelic::Agent::Datastores::Redis.safe_from_third_party_gem?
  end

  executes do
    NewRelic::Agent.logger.info 'Installing Redis Instrumentation'

    Redis::Client.class_eval do
      alias_method :call_without_new_relic, :call

      if RUBY_VERSION < "2.7.0"
        def call(*args, &block)
          operation = args[0][0]
          statement = ::NewRelic::Agent::Datastores::Redis.format_command(args[0])
  
          hostname = NewRelic::Agent::Instrumentation::Redis.host_for(self)
          port_path_or_id = NewRelic::Agent::Instrumentation::Redis.port_path_or_id_for(self)
  
          segment = NewRelic::Agent::Tracer.start_datastore_segment(
            product: NewRelic::Agent::Datastores::Redis::PRODUCT_NAME,
            operation: operation,
            host: hostname,
            port_path_or_id: port_path_or_id,
            database_name: db
          )
          begin
            segment.notice_nosql_statement(statement) if statement
            NewRelic::Agent::Tracer.capture_segment_error segment do
              call_without_new_relic(*args, &block)
            end
          ensure
            segment.finish if segment
          end
        end
      else
        def call(*args, **kwargs, &block)
          operation = args[0][0]
          statement = ::NewRelic::Agent::Datastores::Redis.format_command(args[0])
  
          hostname = NewRelic::Agent::Instrumentation::Redis.host_for(self)
          port_path_or_id = NewRelic::Agent::Instrumentation::Redis.port_path_or_id_for(self)
  
          segment = NewRelic::Agent::Tracer.start_datastore_segment(
            product: NewRelic::Agent::Datastores::Redis::PRODUCT_NAME,
            operation: operation,
            host: hostname,
            port_path_or_id: port_path_or_id,
            database_name: db
          )
          begin
            segment.notice_nosql_statement(statement) if statement
            NewRelic::Agent::Tracer.capture_segment_error segment do
              call_without_new_relic(*args, **kwargs, &block)
            end
          ensure
            segment.finish if segment
          end
        end
      end



      alias_method :call_pipeline_without_new_relic, :call_pipeline

      if RUBY_VERSION < "2.7.0"
        def call_pipeline(*args, &block)
          pipeline = args[0]
          operation = pipeline.is_a?(::Redis::Pipeline::Multi) ? NewRelic::Agent::Datastores::Redis::MULTI_OPERATION : NewRelic::Agent::Datastores::Redis::PIPELINE_OPERATION
          statement = ::NewRelic::Agent::Datastores::Redis.format_pipeline_commands(pipeline.commands)
  
          hostname = NewRelic::Agent::Instrumentation::Redis.host_for(self)
          port_path_or_id = NewRelic::Agent::Instrumentation::Redis.port_path_or_id_for(self)
  
          segment = NewRelic::Agent::Tracer.start_datastore_segment(
            product: NewRelic::Agent::Datastores::Redis::PRODUCT_NAME,
            operation: operation,
            host: hostname,
            port_path_or_id: port_path_or_id,
            database_name: db
          )
          begin
            segment.notice_nosql_statement(statement)
            NewRelic::Agent::Tracer.capture_segment_error segment do
              call_pipeline_without_new_relic(*args, &block)
            end
          ensure
            segment.finish if segment
          end
        end
      else
        def call_pipeline(*args, **kwargs, &block)
          pipeline = args[0]
          operation = pipeline.is_a?(::Redis::Pipeline::Multi) ? NewRelic::Agent::Datastores::Redis::MULTI_OPERATION : NewRelic::Agent::Datastores::Redis::PIPELINE_OPERATION
          statement = ::NewRelic::Agent::Datastores::Redis.format_pipeline_commands(pipeline.commands)
  
          hostname = NewRelic::Agent::Instrumentation::Redis.host_for(self)
          port_path_or_id = NewRelic::Agent::Instrumentation::Redis.port_path_or_id_for(self)
  
          segment = NewRelic::Agent::Tracer.start_datastore_segment(
            product: NewRelic::Agent::Datastores::Redis::PRODUCT_NAME,
            operation: operation,
            host: hostname,
            port_path_or_id: port_path_or_id,
            database_name: db
          )
          begin
            segment.notice_nosql_statement(statement)
            NewRelic::Agent::Tracer.capture_segment_error segment do
              call_pipeline_without_new_relic(*args, **kwargs, &block)
            end
          ensure
            segment.finish if segment
          end
        end
      end

      alias_method :connect_without_new_relic, :connect

      if RUBY_VERSION < "2.7.0"
        def connect(*args, &block)
          hostname = NewRelic::Agent::Instrumentation::Redis.host_for(self)
          port_path_or_id = NewRelic::Agent::Instrumentation::Redis.port_path_or_id_for(self)
  
          segment = NewRelic::Agent::Tracer.start_datastore_segment(
            product: NewRelic::Agent::Datastores::Redis::PRODUCT_NAME,
            operation: NewRelic::Agent::Datastores::Redis::CONNECT,
            host: hostname,
            port_path_or_id: port_path_or_id,
            database_name: db
          )
  
          begin
            NewRelic::Agent::Tracer.capture_segment_error segment do
              connect_without_new_relic(*args, &block)
            end
          ensure
            segment.finish if segment
          end
        end
      else
        def connect(*args, **kwargs, &block)
          hostname = NewRelic::Agent::Instrumentation::Redis.host_for(self)
          port_path_or_id = NewRelic::Agent::Instrumentation::Redis.port_path_or_id_for(self)
  
          segment = NewRelic::Agent::Tracer.start_datastore_segment(
            product: NewRelic::Agent::Datastores::Redis::PRODUCT_NAME,
            operation: NewRelic::Agent::Datastores::Redis::CONNECT,
            host: hostname,
            port_path_or_id: port_path_or_id,
            database_name: db
          )
  
          begin
            NewRelic::Agent::Tracer.capture_segment_error segment do
              connect_without_new_relic(*args, **kwargs, &block)
            end
          ensure
            segment.finish if segment
          end
        end
      end

    end
  end
end
