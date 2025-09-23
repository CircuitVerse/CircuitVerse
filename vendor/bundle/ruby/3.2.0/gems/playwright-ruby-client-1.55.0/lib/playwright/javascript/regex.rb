module Playwright
  module JavaScript
    class Regex
      def initialize(regexp)
        unless regexp.is_a?(Regexp)
          raise ArgumentError("Argument must be a Regexp: #{regexp} (#{regexp.class})")
        end

        @source = regexp.source
        @flag = flag_for(regexp)
      end

      attr_reader :source, :flag

      private def flag_for(regexp)
        flags = []
        flags << 'ms' if (regexp.options & Regexp::MULTILINE) != 0
        flags << 'i' if (regexp.options & Regexp::IGNORECASE) != 0
        flags.join('')
      end
    end
  end
end
