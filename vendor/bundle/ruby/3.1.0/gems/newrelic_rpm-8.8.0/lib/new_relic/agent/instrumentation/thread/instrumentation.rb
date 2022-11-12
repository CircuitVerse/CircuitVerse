# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  module Agent
    module Instrumentation
      module MonitoredThread
        attr_reader :nr_parent_thread_id

        def initialize_with_newrelic_tracing
          @nr_parent_thread_id = ::Thread.current.object_id
          yield
        end

        def add_thread_tracing(*args, &block)
          return block if skip_tracing?
          NewRelic::Agent::Tracer.thread_block_with_current_transaction(*args, &block)
        end

        def skip_tracing?
          !NewRelic::Agent.config[:'instrumentation.thread.tracing']
        end
      end
    end
  end
end
