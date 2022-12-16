# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic::Agent::Instrumentation
  module Rack
    module Chain
      def self.instrument! builder_class
        NewRelic::Agent::Instrumentation::RackBuilder.track_deferred_detection builder_class

        builder_class.class_eval do
          include ::NewRelic::Agent::Instrumentation::RackBuilder

          def to_app_with_newrelic_deferred_dependency_detection
            with_deferred_dependency_detection { to_app_without_newrelic }
          end

          alias_method :to_app_without_newrelic, :to_app
          alias_method :to_app, :to_app_with_newrelic_deferred_dependency_detection

          if ::NewRelic::Agent::Instrumentation::RackHelpers.middleware_instrumentation_enabled?
            ::NewRelic::Agent.logger.info "Installing #{builder_class} middleware instrumentation"

            def run_with_newrelic(app, *args)
              run_with_tracing(app) { |wrapped_app| run_without_newrelic(wrapped_app, *args) }
            end

            alias_method :run_without_newrelic, :run
            alias_method :run, :run_with_newrelic

            def use_with_newrelic(middleware_class, *args, &block)
              use_with_tracing(middleware_class) { |wrapped_class| use_without_newrelic(wrapped_class, *args, &block) }
            end
            ruby2_keywords(:use_with_newrelic) if respond_to?(:ruby2_keywords, true)

            alias_method :use_without_newrelic, :use
            alias_method :use, :use_with_newrelic
          end
        end
      end
    end

    module URLMap
      module Chain
        def self.instrument! url_map_class
          url_map_class.class_eval do
            alias_method :initialize_without_newrelic, :initialize

            def initialize(map = {})
              traced_map = ::NewRelic::Agent::Instrumentation::RackURLMap.generate_traced_map(map)
              initialize_without_newrelic(traced_map)
            end
          end
        end
      end
    end
  end
end
