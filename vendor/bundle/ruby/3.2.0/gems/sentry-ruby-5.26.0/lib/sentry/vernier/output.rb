# frozen_string_literal: true

require "json"
require "rbconfig"

module Sentry
  module Vernier
    class Output
      include Profiler::Helpers

      attr_reader :profile

      def initialize(profile, project_root:, in_app_pattern:, app_dirs_pattern:)
        @profile = profile
        @project_root = project_root
        @in_app_pattern = in_app_pattern
        @app_dirs_pattern = app_dirs_pattern
      end

      def to_h
        @to_h ||= {
          frames: frames,
          stacks: stacks,
          samples: samples,
          thread_metadata: thread_metadata
        }
      end

      private

      def thread_metadata
        profile.threads.map { |thread_id, thread_info|
          [thread_id, { name: thread_info[:name] }]
        }.to_h
      end

      def samples
        profile.threads.flat_map { |thread_id, thread_info|
          started_at = thread_info[:started_at]
          samples, timestamps = thread_info.values_at(:samples, :timestamps)

          samples.zip(timestamps).map { |stack_id, timestamp|
            elapsed_since_start_ns = timestamp - started_at

            next if elapsed_since_start_ns < 0

            {
              thread_id: thread_id.to_s,
              stack_id: stack_id,
              elapsed_since_start_ns: elapsed_since_start_ns.to_s
            }
          }.compact
        }
      end

      def frames
        funcs = stack_table_hash[:frame_table].fetch(:func)
        lines = stack_table_hash[:func_table].fetch(:first_line)

        funcs.map do |idx|
          function, mod = split_module(stack_table_hash[:func_table][:name][idx])

          abs_path = stack_table_hash[:func_table][:filename][idx]
          in_app = in_app?(abs_path)
          filename = compute_filename(abs_path, in_app)

          {
            function: function,
            module: mod,
            filename: filename,
            abs_path: abs_path,
            lineno: (lineno = lines[idx]) > 0 ? lineno : nil,
            in_app: in_app
          }.compact
        end
      end

      def stacks
        profile._stack_table.stack_count.times.map do |stack_id|
          profile.stack(stack_id).frames.map(&:idx)
        end
      end

      def stack_table_hash
        @stack_table_hash ||= profile._stack_table.to_h
      end
    end
  end
end
