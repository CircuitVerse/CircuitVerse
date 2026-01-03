module Playwright
  class RouteHandler
    class CountDown
      def initialize(count)
        @count = count
      end

      def increment
        return false if expired?

        @count = @count - 1
        true
      end

      def expired?
        @count <= 0
      end
    end

    class StubCounter
      def increment
        true
      end

      def expired?
        false
      end
    end

    # @param url [String]
    # @param base_url [String|nil]
    # @param handler [Proc]
    # @param times [Integer|nil]
    def initialize(url, base_url, handler, times)
      @url_value = url
      @url_matcher = UrlMatcher.new(url, base_url: base_url)
      @handler = handler
      @counter =
        if times
          CountDown.new(times)
        else
          StubCounter.new
        end
    end

    def as_pattern
      @url_matcher.as_pattern
    end

    def match?(url)
      @url_matcher.match?(url)
    end

    def async_handle(route)
      @counter.increment

      Concurrent::Promises.future { @handler.call(route, route.request) }.rescue do |err|
        puts err, err.backtrace
      end
    end

    def expired?
      @counter.expired?
    end

    def same_value?(url:, handler: nil)
      if handler
        @url_value == url && @handler == handler
      else
        @url_value == url
      end
    end

    def self.prepare_interception_patterns(handlers)
      handlers.map(&:as_pattern).compact
    end
  end
end
