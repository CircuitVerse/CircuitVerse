# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  module Agent
    module Configuration
      MASK_DEFAULTS = {
        :'thread_profiler' =>         Proc.new { !NewRelic::Agent::Threading::BacktraceService.is_supported? },
        :'thread_profiler.enabled' => Proc.new { !NewRelic::Agent::Threading::BacktraceService.is_supported? }
      }
    end
  end
end
