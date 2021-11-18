# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/instrumentation/controller_instrumentation'
require 'new_relic/agent/instrumentation/sinatra/transaction_namer'
require 'new_relic/agent/instrumentation/sinatra/ignorer'
require 'new_relic/agent/parameter_filtering'

DependencyDetection.defer do
  @name = :sinatra

  depends_on do
    !NewRelic::Agent.config[:disable_sinatra] &&
      defined?(::Sinatra) && defined?(::Sinatra::Base) &&
      Sinatra::Base.private_method_defined?(:dispatch!) &&
      Sinatra::Base.private_method_defined?(:process_route) &&
      Sinatra::Base.private_method_defined?(:route_eval)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Sinatra instrumentation'
  end

  executes do
    ::Sinatra::Base.class_eval do
      include NewRelic::Agent::Instrumentation::Sinatra

      alias dispatch_without_newrelic dispatch!
      alias dispatch! dispatch_with_newrelic

      alias process_route_without_newrelic process_route
      alias process_route process_route_with_newrelic

      alias route_eval_without_newrelic route_eval
      alias route_eval route_eval_with_newrelic

      register NewRelic::Agent::Instrumentation::Sinatra::Ignorer
    end

    module ::Sinatra
      register NewRelic::Agent::Instrumentation::Sinatra::Ignorer
    end
  end

  executes do
    if Sinatra::Base.respond_to?(:build)
      # These requires are inside an executes block because they require rack, and
      # we can't be sure that rack is available when this file is first required.
      require 'new_relic/rack/agent_hooks'
      require 'new_relic/rack/browser_monitoring'

      ::Sinatra::Base.class_eval do
        class << self
          alias build_without_newrelic build
          alias build build_with_newrelic
        end
      end
    else
      ::NewRelic::Agent.logger.info("Skipping auto-injection of middleware for Sinatra - requires Sinatra 1.2.1+")
    end
  end
end

module NewRelic
  module Agent
    module Instrumentation
      # NewRelic instrumentation for Sinatra applications.  Sinatra actions will
      # appear in the UI similar to controller actions, and have breakdown charts
      # and transaction traces.
      #
      # The actions in the UI will correspond to the pattern expression used
      # to match them, not directly to full URL's.
      module Sinatra
        include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

        # Expected method for supporting ControllerInstrumentation
        def newrelic_request_headers(_)
          request.env
        end

        def self.included(clazz)
          clazz.extend(ClassMethods)
        end

        module ClassMethods
          def newrelic_middlewares
            middlewares = [NewRelic::Rack::BrowserMonitoring]
            if NewRelic::Rack::AgentHooks.needed?
              middlewares << NewRelic::Rack::AgentHooks
            end
            middlewares
          end

          if RUBY_VERSION < "2.7.0"
            def build_with_newrelic(*args, &block)
              unless NewRelic::Agent.config[:disable_sinatra_auto_middleware]
                newrelic_middlewares.each do |middleware_class|
                  try_to_use(self, middleware_class)
                end
              end
              build_without_newrelic(*args, &block)
            end
          else 
            def build_with_newrelic(*args, **kwargs, &block)
              unless NewRelic::Agent.config[:disable_sinatra_auto_middleware]
                newrelic_middlewares.each do |middleware_class|
                  try_to_use(self, middleware_class)
                end
              end
              build_without_newrelic(*args, **kwargs, &block)
            end
          end

          def try_to_use(app, clazz)
            has_middleware = app.middleware.any? { |info| info[0] == clazz }
            app.use(clazz) unless has_middleware
          end
        end

        # Capture last route we've seen. Will set for transaction on route_eval
        if RUBY_VERSION < "2.7.0"
          def process_route_with_newrelic(*args, &block)
            begin
              env["newrelic.last_route"] = args[0]
            rescue => e
              ::NewRelic::Agent.logger.debug("Failed determining last route in Sinatra", e)
            end
  
            process_route_without_newrelic(*args, &block)
          end
        else 
          def process_route_with_newrelic(*args, **kwargs, &block)
            begin
              env["newrelic.last_route"] = args[0]
            rescue => e
              ::NewRelic::Agent.logger.debug("Failed determining last route in Sinatra", e)
            end
  
            process_route_without_newrelic(*args, **kwargs, &block)
          end
        end

        # If a transaction name is already set, this call will tromple over it.
        # This is intentional, as typically passing to a separate route is like
        # an entirely separate transaction, so we pick up the new name.
        #
        # If we're ignored, this remains safe, since set_transaction_name
        # care for the gating on the transaction's existence for us.
        if RUBY_VERSION < "2.7.0"
          def route_eval_with_newrelic(*args, &block)
            begin
              txn_name = TransactionNamer.transaction_name_for_route(env, request)
              unless txn_name.nil?
                ::NewRelic::Agent::Transaction.set_default_transaction_name(
                  "#{self.class.name}/#{txn_name}", :sinatra)
              end
            rescue => e
              ::NewRelic::Agent.logger.debug("Failed during route_eval to set transaction name", e)
            end
  
            route_eval_without_newrelic(*args, &block)
          end
        else
          def route_eval_with_newrelic(*args, **kwargs, &block)
            begin
              txn_name = TransactionNamer.transaction_name_for_route(env, request)
              unless txn_name.nil?
                ::NewRelic::Agent::Transaction.set_default_transaction_name(
                  "#{self.class.name}/#{txn_name}", :sinatra)
              end
            rescue => e
              ::NewRelic::Agent.logger.debug("Failed during route_eval to set transaction name", e)
            end
  
            route_eval_without_newrelic(*args, **kwargs, &block)
          end
        end

        def dispatch_with_newrelic #THREAD_LOCAL_ACCESS
          request_params = get_request_params
          filtered_params = ParameterFiltering::apply_filters(request.env, request_params || {})

          name = TransactionNamer.initial_transaction_name(request)
          perform_action_with_newrelic_trace(:category => :sinatra,
                                             :name => name,
                                             :params => filtered_params) do
            dispatch_and_notice_errors_with_newrelic
          end
        end

        def get_request_params
          begin
            @request.params
          rescue => e
            NewRelic::Agent.logger.debug("Failed to get params from Rack request.", e)
            nil
          end
        end

        def dispatch_and_notice_errors_with_newrelic
          dispatch_without_newrelic
        ensure
          # Will only see an error raised if :show_exceptions is true, but
          # will always see them in the env hash if they occur
          had_error = env.has_key?('sinatra.error')
          ::NewRelic::Agent.notice_error(env['sinatra.error']) if had_error
        end

        def do_not_trace?
          Ignorer.should_ignore?(self, :routes)
        end

        # Overrides ControllerInstrumentation implementation
        def ignore_apdex?
          Ignorer.should_ignore?(self, :apdex)
        end

        # Overrides ControllerInstrumentation implementation
        def ignore_enduser?
          Ignorer.should_ignore?(self, :enduser)
        end

      end
    end
  end
end
