module Playwright
  module JavaScript
    class VisitorInfo
      def initialize
        @data = {}
        @last_id = 0
      end

      # returns [Integer|nil]
      def ref(object)
        @data[object]
      end

      def log(object)
        if @data[object]
          raise ArgumentError.new("Already visited")
        end

        id = @last_id + 1
        @last_id = id # FIXME: should thread-safe

        @data[object] = id
      end
    end
  end
end
