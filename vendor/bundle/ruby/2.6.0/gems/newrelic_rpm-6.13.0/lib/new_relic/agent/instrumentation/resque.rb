# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

DependencyDetection.defer do
  @name = :resque

  depends_on do
    defined?(::Resque::Job) && !NewRelic::Agent.config[:disable_resque]
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Resque instrumentation'
  end

  executes do
    if NewRelic::Agent.config[:'resque.use_ruby_dns'] && NewRelic::Agent.config[:dispatcher] == :resque
      ::NewRelic::Agent.logger.info 'Requiring resolv-replace'
      require 'resolv'
      require 'resolv-replace'
    end
  end

  executes do
    module ::Resque
      class Job
        include NewRelic::Agent::Instrumentation::ControllerInstrumentation

        alias_method :perform_without_instrumentation, :perform

        def perform
          begin
            perform_action_with_newrelic_trace(
              :name => 'perform',
              :class_name => self.payload_class,
              :category => 'OtherTransaction/ResqueJob') do

              NewRelic::Agent::Transaction.merge_untrusted_agent_attributes(
                args,
                :'job.resque.args',
                NewRelic::Agent::AttributeFilter::DST_NONE)

              perform_without_instrumentation
            end
          ensure
            # Stopping the event loop before flushing the pipe.
            # The goal is to avoid conflict during write.
            NewRelic::Agent.agent.stop_event_loop
            NewRelic::Agent.agent.flush_pipe_data
          end
        end
      end
    end

    if NewRelic::LanguageSupport.can_fork?
      ::Resque.before_first_fork do
        NewRelic::Agent.manual_start(:dispatcher   => :resque,
                                     :sync_startup => true,
                                     :start_channel_listener => true)
      end

      ::Resque.before_fork do |job|
        if ENV['FORK_PER_JOB'] != 'false'
          NewRelic::Agent.register_report_channel(job.object_id)
        end
      end

      ::Resque.after_fork do |job|
        # Only suppress reporting Instance/Busy for forked children
        # Traced errors UI relies on having the parent process report that metric
        NewRelic::Agent.after_fork(:report_to_channel => job.object_id,
                                   :report_instance_busy => false)
      end
    end
  end
end

# call this now so it is memoized before potentially forking worker processes
NewRelic::LanguageSupport.can_fork?
