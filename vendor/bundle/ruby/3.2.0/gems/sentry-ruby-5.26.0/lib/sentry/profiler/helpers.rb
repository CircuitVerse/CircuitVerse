# frozen_string_literal: true

require "securerandom"

module Sentry
  class Profiler
    module Helpers
      def in_app?(abs_path)
        abs_path.match?(@in_app_pattern)
      end

      # copied from stacktrace.rb since I don't want to touch existing code
      # TODO-neel-profiler try to fetch this from stackprof once we patch
      # the native extension
      def compute_filename(abs_path, in_app)
        return nil if abs_path.nil?

        under_project_root = @project_root && abs_path.start_with?(@project_root)

        prefix =
          if under_project_root && in_app
            @project_root
          else
            longest_load_path = $LOAD_PATH.select { |path| abs_path.start_with?(path.to_s) }.max_by(&:size)

            if under_project_root
              longest_load_path || @project_root
            else
              longest_load_path
            end
          end

        prefix ? abs_path[prefix.to_s.chomp(File::SEPARATOR).length + 1..-1] : abs_path
      end

      def split_module(name)
        # last module plus class/instance method
        i = name.rindex("::")
        function = i ? name[(i + 2)..-1] : name
        mod = i ? name[0...i] : nil

        [function, mod]
      end
    end
  end
end
