# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/tracer'
require 'new_relic/agent/instrumentation/controller_instrumentation'
require 'new_relic/agent/instrumentation/middleware_tracing'

module NewRelic
  module Rack
    class AgentMiddleware
      include Agent::Instrumentation::MiddlewareTracing

      attr_reader :transaction_options, :category, :target

      def initialize(app, options={})
        @app = app
        @category = :middleware
        @target   = self
        @transaction_options = {
          :transaction_name => build_transaction_name
        }
      end

      def build_transaction_name
        prefix = ::NewRelic::Agent::Instrumentation::ControllerInstrumentation::TransactionNamer.prefix_for_category(nil, @category)
        "#{prefix}#{self.class.name}/call"
      end

      # If middleware tracing is disabled, we'll still inject our agent-specific
      # middlewares, and still trace those, but we don't want to capture HTTP
      # response codes, since middleware that's outside of ours might change the
      # response code before it goes back to the client.
      def capture_http_response_code(state, result)
        return if NewRelic::Agent.config[:disable_middleware_instrumentation]
        super
      end

      def capture_response_content_type(state, result)
        return if NewRelic::Agent.config[:disable_middleware_instrumentation]
        super
      end
    end
  end
end
