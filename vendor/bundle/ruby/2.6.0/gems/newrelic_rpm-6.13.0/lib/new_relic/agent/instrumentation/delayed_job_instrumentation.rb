# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/instrumentation/controller_instrumentation'

module NewRelic
  module Agent
    module Instrumentation
      module DelayedJob
        module Naming
          module_function

          CLASS_METHOD_DELIMITER     = '.'.freeze
          INSTANCE_METHOD_DELIMITER  = '#'.freeze
          LEGACY_DJ_FORMAT_DELIMITER = ';'.freeze
          LEGACY_DJ_FORMAT_PREFIX    = 'LOAD'.freeze
          LEGACY_DJ_DEFAULT_CLASS    = '(unknown class)'.freeze

          def name_from_payload(payload_object)
            if payload_object.is_a? ::Delayed::PerformableMethod
              # payload_object contains a reference to an object
              # that received an asynchronous method call via .delay or .handle_asynchronously
              "#{object_name(payload_object)}#{delimiter(payload_object)}#{method_name(payload_object)}"
            else
              # payload_object is a user-defined job enqueued via Delayed::Job.enqueue
              payload_object.class.name
            end
          end

          # Older versions of Delayed Job use a semicolon-delimited string to stash the class name.
          # The format of this string is "LOAD;<class name>;<ORM ID>"
          def legacy_performable_method?(payload_object)
            payload_object.object.is_a?(String) && payload_object.object.start_with?(LEGACY_DJ_FORMAT_PREFIX)
          end

          # If parsing for the class name fails, return a sensible default
          def class_name_from_legacy_performable_method(payload_object)
            payload_object.object.split(LEGACY_DJ_FORMAT_DELIMITER)[1] || LEGACY_DJ_DEFAULT_CLASS
          end

          def object_name(payload_object)
            if payload_object.object.is_a?(Class)
              payload_object.object.to_s
            elsif legacy_performable_method?(payload_object)
              class_name_from_legacy_performable_method(payload_object)
            else
              payload_object.object.class.name
            end
          end

          def delimiter(payload_object)
            if payload_object.object.is_a?(Class)
              CLASS_METHOD_DELIMITER
            else
              INSTANCE_METHOD_DELIMITER
            end
          end

          # DelayedJob's interface for the async method's name varies across the gem's versions
          def method_name(payload_object)
            if payload_object.respond_to?(:method_name)
              payload_object.method_name
            else
              # early versions of Delayed Job override Object#method with the method name
              payload_object.method
            end
          end
        end
      end
    end
  end
end

DependencyDetection.defer do
  @name = :delayed_job

  depends_on do
    !NewRelic::Agent.config[:disable_dj]
  end

  depends_on do
    defined?(::Delayed) && defined?(::Delayed::Worker) && !NewRelic::Agent.config[:disable_dj]
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing DelayedJob instrumentation [part 1/2]'
  end

  executes do
    Delayed::Worker.class_eval do

      if RUBY_VERSION < "2.7.0"
        def initialize_with_new_relic(*args)
          initialize_without_new_relic(*args)
          worker_name = case
                        when self.respond_to?(:name) then self.name
                        when self.class.respond_to?(:default_name) then self.class.default_name
                        end
          NewRelic::DelayedJobInjection.worker_name = worker_name
  
          if defined?(::Delayed::Job) && ::Delayed::Job.method_defined?(:invoke_job) &&
            !(::Delayed::Job.method_defined?(:invoke_job_without_new_relic) )
  
            ::NewRelic::Agent.logger.info 'Installing DelayedJob instrumentation [part 2/2]'
            install_newrelic_job_tracer
            NewRelic::Control.instance.init_plugin :dispatcher => :delayed_job
          else
            NewRelic::Agent.logger.warn("Did not find a Delayed::Job class responding to invoke_job, aborting DJ instrumentation")
          end
        end
      else
        def initialize_with_new_relic(*args, **kwargs)
          initialize_without_new_relic(*args, **kwargs)
          worker_name = case
                        when self.respond_to?(:name) then self.name
                        when self.class.respond_to?(:default_name) then self.class.default_name
                        end
          NewRelic::DelayedJobInjection.worker_name = worker_name

          if defined?(::Delayed::Job) && ::Delayed::Job.method_defined?(:invoke_job) &&
            !(::Delayed::Job.method_defined?(:invoke_job_without_new_relic) )

            ::NewRelic::Agent.logger.info 'Installing DelayedJob instrumentation [part 2/2]'
            install_newrelic_job_tracer
            NewRelic::Control.instance.init_plugin :dispatcher => :delayed_job
          else
            NewRelic::Agent.logger.warn("Did not find a Delayed::Job class responding to invoke_job, aborting DJ instrumentation")
          end
        end
      end

      alias initialize_without_new_relic initialize
      alias initialize initialize_with_new_relic

      NR_TRANSACTION_CATEGORY = 'OtherTransaction/DelayedJob'.freeze

      def install_newrelic_job_tracer
        Delayed::Job.class_eval do
          include NewRelic::Agent::Instrumentation::ControllerInstrumentation

          alias_method :invoke_job_without_new_relic, :invoke_job

          if RUBY_VERSION < "2.7.0"
            def invoke_job(*args, &block)
              options = {
                :category => NR_TRANSACTION_CATEGORY,
                :path => ::NewRelic::Agent::Instrumentation::DelayedJob::Naming.name_from_payload(payload_object)
              }
  
              perform_action_with_newrelic_trace(options) do
                invoke_job_without_new_relic(*args, &block)
              end
            end
          else
            def invoke_job(*args, **kwargs, &block)
              options = {
                :category => NR_TRANSACTION_CATEGORY,
                :path => ::NewRelic::Agent::Instrumentation::DelayedJob::Naming.name_from_payload(payload_object)
              }
  
              perform_action_with_newrelic_trace(options) do
                invoke_job_without_new_relic(*args, **kwargs, &block)
              end
            end
          end

        end
      end
    end
  end
end
