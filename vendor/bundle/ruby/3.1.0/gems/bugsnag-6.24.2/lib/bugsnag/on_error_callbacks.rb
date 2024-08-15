module Bugsnag
  # @api private
  class OnErrorCallbacks
    def initialize(next_middleware, callbacks)
      @next_middleware = next_middleware
      @callbacks = callbacks
    end

    ##
    # @param report [Report]
    def call(report)
      @callbacks.each do |callback|
        begin
          should_continue = callback.call(report)
        rescue StandardError => e
          Bugsnag.configuration.warn("Error occurred in on_error callback: '#{e}'")
          Bugsnag.configuration.warn("on_error callback stacktrace: #{e.backtrace.inspect}")
        end

        # If a callback returns false, we ignore the report and stop running callbacks
        # Note that we explicitly check for 'false' so that callbacks don't need
        # to return anything (i.e. can return 'nil') and we still continue
        next unless should_continue == false

        report.ignore!

        break
      end

      @next_middleware.call(report)
    end
  end
end
