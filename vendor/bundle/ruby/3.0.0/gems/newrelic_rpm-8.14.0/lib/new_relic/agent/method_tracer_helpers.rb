# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.
# frozen_string_literal: true

module NewRelic
  module Agent
    module MethodTracerHelpers
      # These are code level metrics (CLM) attributes. For Ruby, they map like so:
      #   filepath: full path to an .rb file on disk
      #   lineno: the line number a Ruby method is defined on within a given .rb file
      #   function: the name of the Ruby method
      #   namespace: the Ruby class' namespace as a string, ex: 'MyModule::MyClass'
      SOURCE_CODE_INFORMATION_PARAMETERS = %i[filepath lineno function namespace].freeze
      SOURCE_CODE_INFORMATION_FAILURE_METRIC = "Supportability/CodeLevelMetrics/Ruby/Failure".freeze
      MAX_ALLOWED_METRIC_DURATION = 1_000_000_000 # roughly 31 years

      extend self

      def trace_execution_scoped(metric_names, options = NewRelic::EMPTY_HASH) # THREAD_LOCAL_ACCESS
        return yield unless NewRelic::Agent::Tracer.state.is_execution_traced?

        metric_names = Array(metric_names)
        first_name = metric_names.shift
        return yield unless first_name

        segment = NewRelic::Agent::Tracer.start_segment(
          name: first_name,
          unscoped_metrics: metric_names
        )

        segment.record_metrics = false if options[:metric] == false

        unless !options.key?(:code_information) || options[:code_information].nil? || options[:code_information].empty?
          segment.code_information = options[:code_information]
        end

        Tracer.capture_segment_error(segment) { yield }
      ensure
        ::NewRelic::Agent::Transaction::Segment.finish(segment)
      end

      def code_information(object, method_name)
        return ::NewRelic::EMPTY_HASH unless clm_enabled? && object && method_name

        @code_information ||= {}
        cache_key = "#{object.object_id}#{method_name}".freeze
        return @code_information[cache_key] if @code_information.key?(cache_key)

        namespace, location, is_class_method = namespace_and_location(object, method_name.to_sym)

        @code_information[cache_key] = {filepath: location.first,
                                        lineno: location.last,
                                        function: "#{'self.' if is_class_method}#{method_name}",
                                        namespace: namespace}.freeze
      rescue => e
        ::NewRelic::Agent.logger.warn("Unable to determine source code info for '#{object}', " \
                                        "method '#{method_name}' - #{e.class}: #{e.message}")
        ::NewRelic::Agent.increment_metric(SOURCE_CODE_INFORMATION_FAILURE_METRIC, 1)
        ::NewRelic::EMPTY_HASH
      end

      private

      def clm_enabled?
        ::NewRelic::Agent.config[:'code_level_metrics.enabled']
      end

      # The string representation of a singleton class looks like
      # '#<Class:MyModule::MyClass>'. Return the 'MyModule::MyClass' part of
      # that string
      def klass_name(object)
        name = Regexp.last_match(1) if object.to_s =~ /^#<Class:(.*)>$/
        return name if name

        raise "Unable to glean a class name from string '#{object}'"
      end

      # get at the underlying class from the singleton class
      #
      # note: even with the regex hit from klass_name(), `Object.const_get`
      # is more performant than iterating through `ObjectSpace`
      def klassify_singleton(object)
        Object.const_get(klass_name(object))
      end

      # determine the namespace (class name including all module names in scope)
      # and source code location (file path and line number) for the given
      # object and method name
      #
      # traced class methods:
      #     * object is a singleton class, `#<Class::MyClass>`
      #     * get at the underlying non-singleton class
      #
      # traced instance methods and Rails controller methods:
      #     * object is a class, `MyClass`
      #
      # anonymous class based methods (`c = Class.new { def method; end; }`:
      #     * `#name` returns `nil`, so use '(Anonymous)' instead
      #
      def namespace_and_location(object, method_name)
        klass = object.singleton_class? ? klassify_singleton(object) : object
        name = klass.name || '(Anonymous)'
        is_class_method = false
        method = if (klass.instance_methods + klass.private_instance_methods).include?(method_name)
          klass.instance_method(method_name)
        else
          is_class_method = true
          klass.method(method_name)
        end
        [name, method.source_location, is_class_method]
      end
    end
  end
end
