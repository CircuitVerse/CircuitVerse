# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/range_extensions'
require 'new_relic/agent/guid_generator'

module NewRelic
  module Agent
    class Transaction
      class AbstractSegment
        # This class is the base class for all segments. It is reponsible for
        # timing, naming, and defining lifecycle callbacks. One of the more
        # complex responsibilites of this class is computing exclusive duration.
        # One of the reasons for this complexity is that exclusive time will be
        # computed using time ranges or by recording an aggregate value for
        # a segments children time. The reason for this is that computing
        # exclusive duration using time ranges is expensive and it's only
        # necessary if a segment's children run concurrently, or a segment ends
        # after its parent. We will use the optimized exclusive duration
        # calculation in all other cases.
        #
        attr_reader :start_time, :end_time, :duration, :exclusive_duration, :guid
        attr_accessor :name, :parent, :children_time, :transaction, :transaction_name
        attr_writer :record_metrics, :record_scoped_metric, :record_on_finish
        attr_reader :noticed_error

        def initialize name=nil, start_time=nil
          @name = name
          @transaction_name = nil
          @transaction = nil
          @guid = NewRelic::Agent::GuidGenerator.generate_guid
          @parent = nil
          @params = nil
          @start_time = start_time if start_time
          @end_time = nil
          @duration = 0.0
          @exclusive_duration = 0.0
          @children_time = 0.0
          @children_time_ranges = nil
          @active_children = 0
          @range_recorded = false
          @concurrent_children = false
          @record_metrics = true
          @record_scoped_metric = true
          @record_on_finish = false
          @noticed_error = nil
        end

        def start
          @start_time ||= Time.now
          return unless transaction
          parent.child_start self if parent
        end

        def finish
          @end_time = Time.now
          @duration = end_time.to_f - start_time.to_f
          return unless transaction
          run_complete_callbacks
          finalize if record_on_finish?
        rescue => e
          NewRelic::Agent.logger.error "Exception finishing segment: #{name}", e
        end

        def finished?
          !!@end_time
        end

        def record_metrics?
          @record_metrics
        end

        def record_scoped_metric?
          @record_scoped_metric
        end

        def record_on_finish?
          @record_on_finish
        end

        def finalize
          force_finish unless finished?
          record_exclusive_duration
          record_metrics if record_metrics?
        end

        def params
          @params ||= {}
        end

        def params?
          !!@params
        end

        def time_range
          @start_time.to_f .. @end_time.to_f
        end

        def children_time_ranges
          @children_time_ranges ||= []
        end

        def children_time_ranges?
          !!@children_time_ranges
        end

        def concurrent_children?
          @concurrent_children
        end

        INSPECT_IGNORE = [:@transaction, :@transaction_state].freeze

        def inspect
          ivars = (instance_variables - INSPECT_IGNORE).inject([]) do |memo, var_name|
            memo << "#{var_name}=#{instance_variable_get(var_name).inspect}"
          end
          sprintf('#<%s:0x%x %s>', self.class.name, object_id, ivars.join(', '))
        end

        # callback for subclasses to override
        def transaction_assigned
        end

        def set_noticed_error noticed_error
          if @noticed_error
            NewRelic::Agent.logger.debug \
              "Segment: #{name} overwriting previously noticed " \
              "error: #{@noticed_error.inspect} with: #{noticed_error.inspect}"
          end
          @noticed_error = noticed_error
        end

        def notice_error exception, options={}
          if Agent.config[:high_security]
            NewRelic::Agent.logger.debug \
              "Segment: #{name} ignores notice_error for " \
              "error: #{exception.inspect} because :high_security is enabled"
          else
            NewRelic::Agent.instance.error_collector.notice_segment_error self, exception, options
          end
        end

        def noticed_error_attributes
          return unless @noticed_error
          @noticed_error.attributes_from_notice_error
        end

        protected

        attr_writer :range_recorded

        def range_recorded?
          @range_recorded
        end

        def child_start segment
          @active_children += 1
          @concurrent_children = @concurrent_children || @active_children > 1

          transaction.async = true if @concurrent_children
        end

        def child_complete segment
          @active_children -= 1
          record_child_time segment

          if finished?
            transaction.async = true
            parent.descendant_complete self, segment
          end
        end

        # When a child segment completes after its parent, we need to propagate
        # the information about the descendant further up the tree so that
        # ancestors can properly account for exclusive time. Once we've reached
        # an ancestor whose end time is greater than or equal to the descendant's
        # we can stop the propagation. We pass along the direct child so we can
        # make any corrections needed for exclusive time calculation.

        def descendant_complete child, descendant
          RangeExtensions.merge_or_append descendant.time_range,
                                            children_time_ranges
          # If this child's time was previously added to this segment's
          # aggregate children time, we need to re-record it using a time range
          # for proper exclusive time calculation
          unless child.range_recorded?
            self.children_time -= child.duration
            record_child_time_as_range child
          end

          if parent && finished? && descendant.end_time >= end_time
            parent.descendant_complete self, descendant
          end
        end

        private

        def force_finish
          finish
          NewRelic::Agent.logger.warn "Segment: #{name} was unfinished at " \
            "the end of transaction. Timing information for this segment's" \
            "parent #{parent.name} in #{transaction.best_name} may be inaccurate."
        end

        def run_complete_callbacks
          segment_complete
          parent.child_complete self if parent
          transaction.segment_complete self
        end

        def record_metrics
          raise NotImplementedError, "Subclasses must implement record_metrics"
        end

        # callback for subclasses to override
        def segment_complete
        end

        def record_child_time child
          if concurrent_children? || finished? && end_time < child.end_time
            record_child_time_as_range child
          else
            record_child_time_as_number child
          end
        end

        def record_child_time_as_range child
          RangeExtensions.merge_or_append child.time_range,
                                          children_time_ranges
          child.range_recorded = true
        end

        def record_child_time_as_number child
          self.children_time += child.duration
        end

        def record_exclusive_duration
          overlapping_duration = if children_time_ranges?
            RangeExtensions.compute_overlap time_range, children_time_ranges
          else
            0.0
          end

          @exclusive_duration = duration - children_time - overlapping_duration
          transaction.total_time += @exclusive_duration
          params[:exclusive_duration_millis] = @exclusive_duration * 1000 if transaction.async?
        end

        def metric_cache
          transaction.metrics
        end

        def transaction_state
          @transaction_state ||= if @transaction
            transaction.state
          else
            Tracer.state
          end
        end
      end
    end
  end
end
