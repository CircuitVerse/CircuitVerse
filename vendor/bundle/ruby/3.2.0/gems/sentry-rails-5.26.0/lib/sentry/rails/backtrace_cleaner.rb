# frozen_string_literal: true

require "active_support/backtrace_cleaner"
require "active_support/core_ext/string/access"

module Sentry
  module Rails
    class BacktraceCleaner < ActiveSupport::BacktraceCleaner
      APP_DIRS_PATTERN = /\A(?:\.\/)?(?:app|config|lib|test|\(\w*\))/
      RENDER_TEMPLATE_PATTERN = /:in (?:`|').*_\w+_{2,3}\d+_\d+'/

      def initialize
        super
        # We don't want any default silencers because they're too aggressive
        remove_silencers!
        # We don't want any default filters because Rails 7.2 starts shortening the paths. See #2472
        remove_filters!

        add_filter do |line|
          if line =~ RENDER_TEMPLATE_PATTERN
            line.sub(RENDER_TEMPLATE_PATTERN, "")
          else
            line
          end
        end
      end
    end
  end
end
