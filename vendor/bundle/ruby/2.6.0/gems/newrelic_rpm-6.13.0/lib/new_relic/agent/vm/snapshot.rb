# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  module Agent
    module VM
      class Snapshot
        attr_accessor :gc_total_time, :gc_runs, :major_gc_count, :minor_gc_count,
                      :total_allocated_object, :heap_live, :heap_free,
                      :method_cache_invalidations, :constant_cache_invalidations,
                      :thread_count, :taken_at

        def initialize
          @taken_at = Time.now.to_f
        end
      end
    end
  end
end
