# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/coerce'

module NewRelic
  class MetricData
    # a NewRelic::MetricSpec object
    attr_reader :metric_spec
    # the actual statistics object
    attr_accessor :stats

    def initialize(metric_spec, stats)
      @original_spec = nil
      @metric_spec = metric_spec
      self.stats = stats
    end

    def eql?(o)
     (metric_spec.eql? o.metric_spec) && (stats.eql? o.stats)
    end

    def original_spec
      @original_spec || @metric_spec
    end

    # assigns a new metric spec, and retains the old metric spec as
    # @original_spec if it exists currently
    def metric_spec= new_spec
      @original_spec = @metric_spec if @metric_spec
      @metric_spec = new_spec
    end

    def hash
      metric_spec.hash ^ stats.hash
    end

    def to_json(*a)
       %Q[{"metric_spec":#{metric_spec.to_json},"stats":{"total_exclusive_time":#{stats.total_exclusive_time},"min_call_time":#{stats.min_call_time},"call_count":#{stats.call_count},"sum_of_squares":#{stats.sum_of_squares},"total_call_time":#{stats.total_call_time},"max_call_time":#{stats.max_call_time}}}]
    end

    def to_s
      "#{metric_spec.name}(#{metric_spec.scope}): #{stats}"
    end

    def inspect
      "#<MetricData metric_spec:#{metric_spec.inspect}, stats:#{stats.inspect}>"
    end

    include NewRelic::Coerce

    def to_collector_array(encoder=nil)
      stat_key = { 'name' => metric_spec.name, 'scope' => metric_spec.scope }
      [ stat_key,
        [
          int(stats.call_count, stat_key),
          float(stats.total_call_time, stat_key),
          float(stats.total_exclusive_time, stat_key),
          float(stats.min_call_time, stat_key),
          float(stats.max_call_time, stat_key),
          float(stats.sum_of_squares, stat_key)
        ]
      ]
    end
  end
end
