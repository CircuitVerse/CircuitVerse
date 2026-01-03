# frozen_string_literal: true

require "securerandom"
require_relative "../profiler/helpers"
require_relative "output"
require "sentry/utils/uuid"

module Sentry
  module Vernier
    class Profiler
      EMPTY_RESULT = {}.freeze

      attr_reader :started, :event_id, :result

      def initialize(configuration)
        @event_id = Utils.uuid

        @started = false
        @sampled = nil

        @profiling_enabled = defined?(Vernier) && configuration.profiling_enabled?
        @profiles_sample_rate = configuration.profiles_sample_rate
        @project_root = configuration.project_root
        @app_dirs_pattern = configuration.app_dirs_pattern
        @in_app_pattern = Regexp.new("^(#{@project_root}/)?#{@app_dirs_pattern}")
      end

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

      def start
        return unless @sampled
        return if @started

        @started = ::Vernier.start_profile

        log("Started")

        @started
      rescue RuntimeError => e
        # TODO: once Vernier raises something more dedicated, we should catch that instead
        if e.message.include?("Profile already started")
          log("Not started since running elsewhere")
        else
          log("Failed to start: #{e.message}")
        end
      end

      def stop
        return unless @sampled
        return unless @started

        @result = ::Vernier.stop_profile
        @started = false

        log("Stopped")
      rescue RuntimeError => e
        if e.message.include?("Profile not started")
          log("Not stopped since not started")
        else
          log("Failed to stop Vernier: #{e.message}")
        end
      end

      def active_thread_id
        Thread.current.object_id
      end

      def to_hash
        unless @sampled
          record_lost_event(:sample_rate)
          return EMPTY_RESULT
        end

        return EMPTY_RESULT unless result

        { **profile_meta, profile: output.to_h }
      end

      private

      def log(message)
        Sentry.sdk_logger.debug(LOGGER_PROGNAME) { "[Profiler::Vernier] #{message}" }
      end

      def record_lost_event(reason)
        Sentry.get_current_client&.transport&.record_lost_event(reason, "profile")
      end

      def profile_meta
        {
          event_id: @event_id,
          version: "1",
          platform: "ruby"
        }
      end

      def output
        @output ||= Output.new(
          result,
          project_root: @project_root,
          app_dirs_pattern: @app_dirs_pattern,
          in_app_pattern: @in_app_pattern
        )
      end
    end
  end
end
