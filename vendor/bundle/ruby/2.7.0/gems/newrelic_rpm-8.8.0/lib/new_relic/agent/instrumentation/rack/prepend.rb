# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic::Agent::Instrumentation
  module Rack
    module URLMap
      module Prepend
        def initialize(map = {})
          super ::NewRelic::Agent::Instrumentation::RackURLMap.generate_traced_map(map)
        end
      end
    end

    module Prepend
      include ::NewRelic::Agent::Instrumentation::RackBuilder

      def self.prepended builder_class
        NewRelic::Agent::Instrumentation::RackBuilder.track_deferred_detection builder_class
      end

      def to_app
        with_deferred_dependency_detection { super }
      end

      def run(app, *args)
        run_with_tracing(app) { |wrapped_app| super(wrapped_app, *args) }
      end

      def use(middleware_class, *args, &blk)
        use_with_tracing(middleware_class) { |wrapped_class| super(wrapped_class, *args, &blk) }
      end
      ruby2_keywords(:use) if respond_to?(:ruby2_keywords, true)
    end
  end
end
