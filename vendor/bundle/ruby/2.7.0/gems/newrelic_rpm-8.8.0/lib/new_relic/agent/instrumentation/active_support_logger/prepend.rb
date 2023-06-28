# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic::Agent::Instrumentation
  module ActiveSupportLogger::Prepend
    include NewRelic::Agent::Instrumentation::ActiveSupportLogger
    def broadcast(logger)
      broadcast_with_tracing(logger) { super }
    end
  end
end
