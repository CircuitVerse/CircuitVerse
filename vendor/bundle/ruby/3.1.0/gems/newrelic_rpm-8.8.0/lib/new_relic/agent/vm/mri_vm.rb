# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'thread'
require 'new_relic/agent/vm/snapshot'

module NewRelic
  module Agent
    module VM
      class MriVM
        def snapshot
          snap = Snapshot.new
          gather_stats(snap)
          snap
        end

        def gather_stats(snap)
          gather_gc_stats(snap)
          gather_ruby_vm_stats(snap)
          gather_thread_stats(snap)
          gather_gc_time(snap)
        end

        def gather_gc_stats(snap)
          if supports?(:gc_runs)
            snap.gc_runs = GC.count
          end

          if GC.respond_to?(:stat)
            gc_stats = GC.stat
            snap.total_allocated_object = gc_stats[:total_allocated_objects] || gc_stats[:total_allocated_object]
            snap.major_gc_count = gc_stats[:major_gc_count]
            snap.minor_gc_count = gc_stats[:minor_gc_count]
            snap.heap_live = gc_stats[:heap_live_slots] || gc_stats[:heap_live_slot] || gc_stats[:heap_live_num]
            snap.heap_free = gc_stats[:heap_free_slots] || gc_stats[:heap_free_slot] || gc_stats[:heap_free_num]
          end
        end

        def gather_gc_time(snap)
          if supports?(:gc_total_time)
            snap.gc_total_time = NewRelic::Agent.instance.monotonic_gc_profiler.total_time_s
          end
        end

        def gather_ruby_vm_stats(snap)
          if supports?(:method_cache_invalidations)
            snap.method_cache_invalidations = RubyVM.stat[:global_method_state]
          end

          if supports?(:constant_cache_invalidations)
            snap.constant_cache_invalidations = gather_constant_cache_invalidations
          end
        end

        def gather_constant_cache_invalidations
          # Ruby >= 3.2 uses :constant_cache
          # see: https://github.com/ruby/ruby/pull/5433 and https://bugs.ruby-lang.org/issues/18589
          # TODO: now that 3.2+ provides more granual cache invalidation data, should we report it instead of summing?
          if RUBY_VERSION >= '3.2.0'
            RubyVM.stat[:constant_cache].values.sum
          # Ruby < 3.2 uses :global_constant_state
          else
            RubyVM.stat[:global_constant_state]
          end
        end

        def gather_thread_stats(snap)
          snap.thread_count = Thread.list.size
        end

        def supports?(key)
          case key
          when :gc_runs, :total_allocated_object, :heap_live, :heap_free, :thread_count
            true
          when :gc_total_time
            NewRelic::LanguageSupport.gc_profiler_enabled?
          when :major_gc_count
            RUBY_VERSION >= '2.1.0'
          when :minor_gc_count
            RUBY_VERSION >= '2.1.0'
          when :method_cache_invalidations
            RUBY_VERSION >= '2.1.0' && RUBY_VERSION < '3.0.0'
          when :constant_cache_invalidations
            RUBY_VERSION >= '2.1.0'
          else
            false
          end
        end
      end
    end
  end
end
