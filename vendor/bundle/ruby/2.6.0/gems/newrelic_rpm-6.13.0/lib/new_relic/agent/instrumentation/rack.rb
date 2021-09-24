# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/instrumentation/controller_instrumentation'

module NewRelic
  module Agent
    module Instrumentation
      module RackHelpers
        def self.version_supported?
          rack_version_supported? || puma_rack_version_supported?
        end

        def self.rack_version_supported?
          return false unless defined? ::Rack

          version = Gem::Version.new(::Rack.release)
          min_version = Gem::Version.new('1.1.0')
          version >= min_version
        end

        def self.puma_rack_version_supported?
          return false unless defined? ::Puma::Const::PUMA_VERSION

          version = Gem::Version.new(::Puma::Const::PUMA_VERSION)
          min_version = Gem::Version.new('2.12.0')
          version >= min_version
        end

        def self.middleware_instrumentation_enabled?
          version_supported? && !::NewRelic::Agent.config[:disable_middleware_instrumentation]
        end

        def self.check_for_late_instrumentation(app)
          return if defined?(@checked_for_late_instrumentation) && @checked_for_late_instrumentation
          @checked_for_late_instrumentation = true
          if middleware_instrumentation_enabled?
            if ::NewRelic::Agent::Instrumentation::MiddlewareProxy.needs_wrapping?(app)
              ::NewRelic::Agent.logger.info("We weren't able to instrument all of your Rack middlewares.",
                                            "To correct this, ensure you 'require \"newrelic_rpm\"' before setting up your middleware stack.")
            end
          end
        end

        def self.instrument_builder builder_class
          ::NewRelic::Agent.logger.info "Installing deferred #{builder_class} instrumentation"

          builder_class.class_eval do
            class << self
              attr_accessor :_nr_deferred_detection_ran
            end
            self._nr_deferred_detection_ran = false

            include ::NewRelic::Agent::Instrumentation::RackBuilder

            alias_method :to_app_without_newrelic, :to_app
            alias_method :to_app, :to_app_with_newrelic_deferred_dependency_detection

            if ::NewRelic::Agent::Instrumentation::RackHelpers.middleware_instrumentation_enabled?
              ::NewRelic::Agent.logger.info "Installing #{builder_class} middleware instrumentation"
              alias_method :run_without_newrelic, :run
              alias_method :run, :run_with_newrelic

              alias_method :use_without_newrelic, :use
              alias_method :use, :use_with_newrelic
            end
          end

          def self.instrument_url_map url_map_class
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

      module RackBuilder

        if RUBY_VERSION < "2.7.0"
          def run_with_newrelic(app, *args)
            if ::NewRelic::Agent::Instrumentation::RackHelpers.middleware_instrumentation_enabled?
              wrapped_app = ::NewRelic::Agent::Instrumentation::MiddlewareProxy.wrap(app, true)
              run_without_newrelic(wrapped_app, *args)
            else
              run_without_newrelic(app, *args)
            end
          end
        else
          def run_with_newrelic(app, *args, **kwargs)
            if ::NewRelic::Agent::Instrumentation::RackHelpers.middleware_instrumentation_enabled?
              wrapped_app = ::NewRelic::Agent::Instrumentation::MiddlewareProxy.wrap(app, true)
              run_without_newrelic(wrapped_app, *args, **kwargs)
            else
              run_without_newrelic(app, *args, **kwargs)
            end
          end          
        end

        if RUBY_VERSION < "2.7.0"
          def use_with_newrelic(middleware_class, *args, &blk)
            if ::NewRelic::Agent::Instrumentation::RackHelpers.middleware_instrumentation_enabled?
              wrapped_middleware_class = ::NewRelic::Agent::Instrumentation::MiddlewareProxy.for_class(middleware_class)
              use_without_newrelic(wrapped_middleware_class, *args, &blk)
            else
              use_without_newrelic(middleware_class, *args, &blk)
            end
          end
        else
          def use_with_newrelic(middleware_class, *args, **kwargs, &blk)
            if ::NewRelic::Agent::Instrumentation::RackHelpers.middleware_instrumentation_enabled?
              wrapped_middleware_class = ::NewRelic::Agent::Instrumentation::MiddlewareProxy.for_class(middleware_class)
              use_without_newrelic(wrapped_middleware_class, *args, **kwargs, &blk)
            else
              use_without_newrelic(middleware_class, *args, **kwargs, &blk)
            end
          end  
        end

        # We patch this method for a reason that actually has nothing to do with
        # instrumenting rack itself. It happens to be a convenient and
        # easy-to-hook point that happens late in the startup sequence of almost
        # every application, making it a good place to do a final call to
        # DependencyDetection.detect!, since all libraries are likely loaded at
        # this point.
        def to_app_with_newrelic_deferred_dependency_detection
          unless self.class._nr_deferred_detection_ran
            NewRelic::Agent.logger.info "Doing deferred dependency-detection before Rack startup"
            DependencyDetection.detect!
            self.class._nr_deferred_detection_ran = true
          end

          result = to_app_without_newrelic
          ::NewRelic::Agent::Instrumentation::RackHelpers.check_for_late_instrumentation(result)

          result
        end
      end

      module RackURLMap
        def self.generate_traced_map(map)
          map.inject({}) do |traced_map, (url, handler)|
            traced_map[url] = NewRelic::Agent::Instrumentation::MiddlewareProxy.wrap(handler, true)
            traced_map
          end
        end
      end
    end
  end
end

DependencyDetection.defer do
  named :rack

  depends_on do
    defined?(::Rack) && defined?(::Rack::Builder)
  end

  executes do
    ::NewRelic::Agent::Instrumentation::RackHelpers.instrument_builder ::Rack::Builder
  end
end


DependencyDetection.defer do
  named :puma_rack

  depends_on do
    defined?(::Puma::Rack::Builder) && !NewRelic::Agent.config[:disable_puma_rack]
  end

  executes do
    ::NewRelic::Agent::Instrumentation::RackHelpers.instrument_builder ::Puma::Rack::Builder
  end
end

DependencyDetection.defer do
  named :rack_urlmap

  depends_on do
    defined?(::Rack) && defined?(::Rack::URLMap)
  end

  depends_on do
    ::NewRelic::Agent::Instrumentation::RackHelpers.middleware_instrumentation_enabled? &&
      !::NewRelic::Agent.config[:disable_rack]
  end

  executes do
    ::NewRelic::Agent::Instrumentation::RackHelpers.instrument_url_map ::Rack::URLMap
  end
end

DependencyDetection.defer do
  named :puma_rack_urlmap

  depends_on do
    defined? Puma::Rack::URLMap
  end

  depends_on do
    ::NewRelic::Agent::Instrumentation::RackHelpers.middleware_instrumentation_enabled? &&
      !::NewRelic::Agent.config[:disable_puma_rack]
  end

  executes do
    ::NewRelic::Agent::Instrumentation::RackHelpers.instrument_url_map ::Puma::Rack::URLMap
  end
end
