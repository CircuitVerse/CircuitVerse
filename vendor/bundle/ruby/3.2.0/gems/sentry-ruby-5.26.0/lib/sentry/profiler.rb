# frozen_string_literal: true

require "securerandom"
require_relative "profiler/helpers"
require "sentry/utils/uuid"

module Sentry
  class Profiler
    include Profiler::Helpers

    VERSION = "1"
    PLATFORM = "ruby"
    # 101 Hz in microseconds
    DEFAULT_INTERVAL = 1e6 / 101
    MICRO_TO_NANO_SECONDS = 1e3
    MIN_SAMPLES_REQUIRED = 2

    attr_reader :sampled, :started, :event_id

    def initialize(configuration)
      @event_id = Utils.uuid
      @started = false
      @sampled = nil

      @profiling_enabled = defined?(StackProf) && configuration.profiling_enabled?
      @profiles_sample_rate = configuration.profiles_sample_rate
      @project_root = configuration.project_root
      @app_dirs_pattern = configuration.app_dirs_pattern
      @in_app_pattern = Regexp.new("^(#{@project_root}/)?#{@app_dirs_pattern}")
    end

    def start
      return unless @sampled

      @started = StackProf.start(interval: DEFAULT_INTERVAL,
                                 mode: :wall,
                                 raw: true,
                                 aggregate: false)

      @started ? log("Started") : log("Not started since running elsewhere")
    end

    def stop
      return unless @sampled
      return unless @started

      StackProf.stop
      log("Stopped")
    end

    def active_thread_id
      "0"
    end

    # Sets initial sampling decision of the profile.
    # @return [void]
    def set_initial_sample_decision(transaction_sampled)
      unless @profiling_enabled
        @sampled = false
        return
      end

      unless transaction_sampled
        @sampled = false
        log("Discarding profile because transaction not sampled")
        return
      end

      case @profiles_sample_rate
      when 0.0
        @sampled = false
        log("Discarding profile because sample_rate is 0")
        return
      when 1.0
        @sampled = true
        return
      else
        @sampled = Random.rand < @profiles_sample_rate
      end

      log("Discarding profile due to sampling decision") unless @sampled
    end

    def to_hash
      unless @sampled
        record_lost_event(:sample_rate)
        return {}
      end

      return {} unless @started

      results = StackProf.results

      if !results || results.empty? || results[:samples] == 0 || !results[:raw]
        record_lost_event(:insufficient_data)
        return {}
      end

      frame_map = {}

      frames = results[:frames].map.with_index do |(frame_id, frame_data), idx|
        # need to map over stackprof frame ids to ours
        frame_map[frame_id] = idx

        file_path = frame_data[:file]
        lineno = frame_data[:line]
        in_app = in_app?(file_path)
        filename = compute_filename(file_path, in_app)
        function, mod = split_module(frame_data[:name])

        frame_hash = {
          abs_path: file_path,
          function: function,
          filename: filename,
          in_app: in_app
        }

        frame_hash[:module] = mod if mod
        frame_hash[:lineno] = lineno if lineno && lineno >= 0

        frame_hash
      end

      idx = 0
      stacks = []
      num_seen = []

      # extract stacks from raw
      # raw is a single array of [.., len_stack, *stack_frames(len_stack), num_stack_seen , ..]
      while (len = results[:raw][idx])
        idx += 1

        # our call graph is reversed
        stack = results[:raw].slice(idx, len).map { |id| frame_map[id] }.compact.reverse
        stacks << stack

        num_seen << results[:raw][idx + len]
        idx += len + 1

        log("Unknown frame in stack") if stack.size != len
      end

      idx = 0
      elapsed_since_start_ns = 0
      samples = []

      num_seen.each_with_index do |n, i|
        n.times do
          # stackprof deltas are in microseconds
          delta = results[:raw_timestamp_deltas][idx]
          elapsed_since_start_ns += (delta * MICRO_TO_NANO_SECONDS).to_i
          idx += 1

          # Not sure why but some deltas are very small like 0/1 values,
          # they pollute our flamegraph so just ignore them for now.
          # Open issue at https://github.com/tmm1/stackprof/issues/201
          next if delta < 10

          samples << {
            stack_id: i,
            # TODO-neel-profiler we need to patch rb_profile_frames and write our own C extension to enable threading info.
            # Till then, on multi-threaded servers like puma, we will get frames from other active threads when the one
            # we're profiling is idle/sleeping/waiting for IO etc.
            # https://bugs.ruby-lang.org/issues/10602
            thread_id: "0",
            elapsed_since_start_ns: elapsed_since_start_ns.to_s
          }
        end
      end

      log("Some samples thrown away") if samples.size != results[:samples]

      if samples.size <= MIN_SAMPLES_REQUIRED
        log("Not enough samples, discarding profiler")
        record_lost_event(:insufficient_data)
        return {}
      end

      profile = {
        frames: frames,
        stacks: stacks,
        samples: samples
      }

      {
        event_id: @event_id,
        platform: PLATFORM,
        version: VERSION,
        profile: profile
      }
    end

    private

    def log(message)
      Sentry.sdk_logger.debug(LOGGER_PROGNAME) { "[Profiler] #{message}" }
    end

    def record_lost_event(reason)
      Sentry.get_current_client&.transport&.record_lost_event(reason, "profile")
    end
  end
end
