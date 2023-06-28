# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.
# frozen_string_literal: true

module NewRelic::Agent::Instrumentation::Sidekiq
  class Server
    include NewRelic::Agent::Instrumentation::ControllerInstrumentation
    include Sidekiq::ServerMiddleware if defined?(Sidekiq::ServerMiddleware)

    # Client middleware has additional parameters, and our tests use the
    # middleware client-side to work inline.
    def call(worker, msg, queue, *_)
      trace_args = if worker.respond_to?(:newrelic_trace_args)
        worker.newrelic_trace_args(msg, queue)
      else
        self.class.default_trace_args(msg)
      end
      trace_headers = msg.delete(NewRelic::NEWRELIC_KEY)

      perform_action_with_newrelic_trace(trace_args) do
        NewRelic::Agent::Transaction.merge_untrusted_agent_attributes(msg['args'], :'job.sidekiq.args',
          NewRelic::Agent::AttributeFilter::DST_NONE)

        ::NewRelic::Agent::DistributedTracing::accept_distributed_trace_headers(trace_headers, "Other") if ::NewRelic::Agent.config[:'distributed_tracing.enabled']
        yield
      end
    end

    def self.default_trace_args(msg)
      {
        :name => 'perform',
        :class_name => msg['class'],
        :category => 'OtherTransaction/SidekiqJob'
      }
    end
  end
end
