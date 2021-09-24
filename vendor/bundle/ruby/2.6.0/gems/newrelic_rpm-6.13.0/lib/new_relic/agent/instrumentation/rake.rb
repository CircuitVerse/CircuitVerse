# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

DependencyDetection.defer do
  # Why not :rake? newrelic-rake used that name, so avoid conflicting
  named :rake_instrumentation

  depends_on do
    defined?(::Rake) &&
      defined?(::Rake::VERSION) &&
      ::NewRelic::Agent.config[:'disable_rake'] == false &&
      ::NewRelic::Agent.config[:'rake.tasks'].any? &&
      ::NewRelic::Agent::Instrumentation::RakeInstrumentation.should_install?
  end

  executes do
    ::NewRelic::Agent.logger.info  "Installing Rake instrumentation"
    ::NewRelic::Agent.logger.debug "Instrumenting Rake tasks: #{::NewRelic::Agent.config[:'rake.tasks']}"
  end

  executes do
    module Rake
      class Task
        alias_method :invoke_without_newrelic, :invoke


        if RUBY_VERSION < "2.7.0"
          def invoke(*args)
            unless NewRelic::Agent::Instrumentation::RakeInstrumentation.should_trace? name
              return invoke_without_newrelic(*args)
            end
  
            begin
              timeout = NewRelic::Agent.config[:'rake.connect_timeout']
              NewRelic::Agent.instance.wait_on_connect(timeout)
            rescue => e
              NewRelic::Agent.logger.error("Exception in wait_on_connect", e)
              return invoke_without_newrelic(*args)
            end
  
            NewRelic::Agent::Instrumentation::RakeInstrumentation.before_invoke_transaction(self)
  
            NewRelic::Agent::Tracer.in_transaction(name: "OtherTransaction/Rake/invoke/#{name}", category: :rake) do
              NewRelic::Agent::Instrumentation::RakeInstrumentation.record_attributes(args, self)
              invoke_without_newrelic(*args)
            end
          end
        else
          def invoke(*args, **kwargs)
            unless NewRelic::Agent::Instrumentation::RakeInstrumentation.should_trace? name
              return invoke_without_newrelic(*args, **kwargs)
            end
  
            begin
              timeout = NewRelic::Agent.config[:'rake.connect_timeout']
              NewRelic::Agent.instance.wait_on_connect(timeout)
            rescue => e
              NewRelic::Agent.logger.error("Exception in wait_on_connect", e)
              return invoke_without_newrelic(*args, **kwargs)
            end
  
            NewRelic::Agent::Instrumentation::RakeInstrumentation.before_invoke_transaction(self)
  
            NewRelic::Agent::Tracer.in_transaction(name: "OtherTransaction/Rake/invoke/#{name}", category: :rake) do
              NewRelic::Agent::Instrumentation::RakeInstrumentation.record_attributes(args, self)
              invoke_without_newrelic(*args, **kwargs)
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
      module RakeInstrumentation
        def self.should_install?
          is_supported_version? && safe_from_third_party_gem?
        end

        def self.is_supported_version?
          Gem::Version.new(::Rake::VERSION) >= Gem::Version.new("10.0.0")
        end

        def self.safe_from_third_party_gem?
          if NewRelic::LanguageSupport.bundled_gem?("newrelic-rake")
            ::NewRelic::Agent.logger.info("Not installing New Relic supported Rake instrumentation because the third party newrelic-rake gem is present")
            false
          else
            true
          end
        end

        def self.should_trace?(name)
          NewRelic::Agent.config[:'rake.tasks'].any? do |regex|
            regex.match(name)
          end
        end

        def self.instrument_execute_on_prereqs(task)
          task.prerequisite_tasks.each do |child_task|
            instrument_execute(child_task)
          end
        end

        def self.instrument_execute(task)
          return if task.instance_variable_get(:@__newrelic_instrumented_execute)

          task.instance_variable_set(:@__newrelic_instrumented_execute, true)
          task.instance_eval do
            if RUBY_VERSION < "2.7.0"
              def execute(*args, &block)
                NewRelic::Agent::MethodTracer.trace_execution_scoped("Rake/execute/#{self.name}") do
                  super
                end
              end
            else
              def execute(*args, **kwargs, &block)
                NewRelic::Agent::MethodTracer.trace_execution_scoped("Rake/execute/#{self.name}") do
                  super
                end
              end
            end

          end

          instrument_execute_on_prereqs(task)
        end

        def self.instrument_invoke_prerequisites_concurrently(task)
          task.instance_eval do
            def invoke_prerequisites_concurrently(*_)
              NewRelic::Agent::MethodTracer.trace_execution_scoped("Rake/execute/multitask") do
                prereqs = self.prerequisite_tasks.map(&:name).join(", ")
                if txn = ::NewRelic::Agent::Tracer.current_transaction
                  txn.current_segment.params[:statement] = NewRelic::Agent::Database.truncate_query("Couldn't trace concurrent prereq tasks: #{prereqs}")
                end
                super
              end
            end
          end
        end

        def self.before_invoke_transaction(task)
          ensure_at_exit

          # We can't represent overlapping operations yet, so if multitask just
          # make one node and annotate with prereq task names
          if task.application.options.always_multitask
            instrument_invoke_prerequisites_concurrently(task)
          else
            instrument_execute_on_prereqs(task)
          end
        rescue => e
          NewRelic::Agent.logger.error("Error during Rake task invoke", e)
        end

        def self.record_attributes(args, task)
          command_line = task.application.top_level_tasks.join(" ")
          NewRelic::Agent::Transaction.merge_untrusted_agent_attributes({ :command => command_line },
                                                                        :'job.rake',
                                                                        NewRelic::Agent::AttributeFilter::DST_NONE)
          named_args = name_the_args(args, task.arg_names)
          unless named_args.empty?
            NewRelic::Agent::Transaction.merge_untrusted_agent_attributes(named_args,
                                                                          :'job.rake.args',
                                                                          NewRelic::Agent::AttributeFilter::DST_NONE)
          end
        rescue => e
          NewRelic::Agent.logger.error("Error during Rake task attribute recording.", e)
        end

        # Expects literal args passed to the task and array of task names
        # If names are present without matching args, still sets them with nils
        def self.name_the_args(args, names)
          unfulfilled_names_length = names.length - args.length
          if unfulfilled_names_length > 0
            args.concat(Array.new(unfulfilled_names_length))
          end

          result = {}
          args.zip(names).each_with_index do |(value, key), index|
            result[key || index.to_s] = value
          end
          result
        end

        def self.ensure_at_exit
          return if @installed_at_exit

          at_exit do
            # The agent's default at_exit might not default to installing, but
            # if we are running an instrumented rake task, we always want it.
            NewRelic::Agent.shutdown
          end

          @installed_at_exit = true
        end
      end
    end
  end
end
