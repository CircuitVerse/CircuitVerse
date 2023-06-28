# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic::Agent::Instrumentation
  module Typhoeus
    module Prepend
      include NewRelic::Agent::Instrumentation::Typhoeus
      def run(*args)
        with_tracing { super }
      end
    end
  end
end
