# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/prepend_supportability'

DependencyDetection.defer do
  named :activejob

  depends_on do
    defined?(::ActiveJob::Base)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing ActiveJob instrumentation'

    ActiveSupport.on_load(:active_job) do
      ::ActiveJob::Base.around_enqueue do |job, block|
        ::NewRelic::Agent::Instrumentation::ActiveJobHelper.enqueue(job, block)
      end

      ::ActiveJob::Base.around_perform do |job, block|
        ::NewRelic::Agent::Instrumentation::ActiveJobHelper.perform(job, block)
      end

      ::NewRelic::Agent::PrependSupportability.record_metrics_for(::ActiveJob::Base)
    end
  end
end

module NewRelic
  module Agent
    module Instrumentation
      module ActiveJobHelper
        include ::NewRelic::Agent::MethodTracer

        def self.enqueue(job, block)
          run_in_trace(job, block, :Produce)
        end

        def self.perform(job, block)
          state = ::NewRelic::Agent::Tracer.state
          txn = state.current_transaction

          # Don't nest transactions if we're already in a web transaction.
          # Probably inline processing the job if that happens, so just trace.
          if    txn &&  txn.recording_web_transaction?
            run_in_trace(job, block, :Consume)
          elsif txn && !txn.recording_web_transaction?
            ::NewRelic::Agent::Transaction.set_default_transaction_name(
              transaction_name_suffix_for_job(job),
              transaction_category)
            block.call
          else
            run_in_transaction(job, block)
          end
        end

        def self.run_in_trace(job, block, event)
          trace_execution_scoped("MessageBroker/#{adapter}/Queue/#{event}/Named/#{job.queue_name}") do
            block.call
          end
        end

        def self.run_in_transaction(job, block)
          ::NewRelic::Agent::Tracer.in_transaction(name: transaction_name_for_job(job),
                                                   category: :other,
                                                   &block)
        end

        def self.transaction_category
          "OtherTransaction/#{adapter}"
        end

        def self.transaction_name_suffix_for_job(job)
          "#{job.class}/execute"
        end

        def self.transaction_name_for_job(job)
          "#{transaction_category}/#{transaction_name_suffix_for_job(job)}"
        end

        def self.adapter
          adapter_class = if ::ActiveJob::Base.queue_adapter.class == Class
            ::ActiveJob::Base.queue_adapter
          else
            ::ActiveJob::Base.queue_adapter.class
          end

          clean_adapter_name(adapter_class.name)
        end

        ADAPTER_REGEX = /ActiveJob::QueueAdapters::(.*)Adapter/

        def self.clean_adapter_name(name)
          name = "ActiveJob::#{$1}" if ADAPTER_REGEX =~ name
          name
        end
      end
    end
  end
end
