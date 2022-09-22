# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.
# frozen_string_literal: true

module NewRelic::Agent::Instrumentation
  module Redis
    PRODUCT_NAME = 'Redis'
    CONNECT = 'connect'
    UNKNOWN = "unknown"
    LOCALHOST = "localhost"
    MULTI_OPERATION = 'multi'
    PIPELINE_OPERATION = 'pipeline'

    def call_with_tracing command, &block
      operation = command[0]
      statement = ::NewRelic::Agent::Datastores::Redis.format_command(command)

      with_tracing(operation, statement) { yield }
    end

    def call_pipeline_with_tracing pipeline
      operation = pipeline.is_a?(::Redis::Pipeline::Multi) ? MULTI_OPERATION : PIPELINE_OPERATION
      statement = ::NewRelic::Agent::Datastores::Redis.format_pipeline_commands(pipeline.commands)

      with_tracing(operation, statement) { yield }
    end

    def connect_with_tracing
      with_tracing(CONNECT) { yield }
    end

    private

    def with_tracing operation, statement = nil
      segment = NewRelic::Agent::Tracer.start_datastore_segment(
        product: PRODUCT_NAME,
        operation: operation,
        host: _nr_hostname,
        port_path_or_id: _nr_port_path_or_id,
        database_name: db
      )
      begin
        segment.notice_nosql_statement(statement) if statement
        NewRelic::Agent::Tracer.capture_segment_error(segment) { yield }
      ensure
        segment.finish if segment
      end
    end

    def _nr_hostname
      self.path ? LOCALHOST : self.host
    rescue => e
      NewRelic::Agent.logger.debug "Failed to retrieve Redis host: #{e}"
      UNKNOWN
    end

    def _nr_port_path_or_id
      self.path || self.port
    rescue => e
      NewRelic::Agent.logger.debug "Failed to retrieve Redis port_path_or_id: #{e}"
      UNKNOWN
    end
  end
end
