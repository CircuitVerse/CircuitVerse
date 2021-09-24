# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  module Agent
    class Transaction
      module Tracing

        attr_reader :current_segment

        def async?
          @async ||= false
        end

        attr_writer :async

        def total_time
          @total_time ||= 0.0
        end

        attr_writer :total_time

        def add_segment segment, parent = nil
          segment.transaction = self
          segment.parent = parent || current_segment
          @current_segment = segment
          if @segments.length < segment_limit
            @segments << segment
          else
            segment.record_on_finish = true
            ::NewRelic::Agent.logger.debug("Segment limit of #{segment_limit} reached, ceasing collection.")
          end
          segment.transaction_assigned
        end

        def segment_complete segment
          @current_segment = segment.parent
        end

        def segment_limit
          Agent.config[:'transaction_tracer.limit_segments']
        end

        private

        def finalize_segments
          segments.each { |s| s.finalize }
        end


        WEB_TRANSACTION_TOTAL_TIME   = "WebTransactionTotalTime".freeze
        OTHER_TRANSACTION_TOTAL_TIME = "OtherTransactionTotalTime".freeze

        def record_total_time_metrics
          total_time_metric = if recording_web_transaction?
            WEB_TRANSACTION_TOTAL_TIME
          else
            OTHER_TRANSACTION_TOTAL_TIME
          end

          @metrics.record_unscoped total_time_metric, total_time
          @metrics.record_unscoped "#{total_time_metric}/#{@frozen_name}", total_time
        end
      end
    end
  end
end
