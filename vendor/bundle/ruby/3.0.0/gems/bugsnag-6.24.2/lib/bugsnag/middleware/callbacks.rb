module Bugsnag::Middleware
  ##
  # Calls all configured callbacks passing an error report
  class Callbacks
    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(report)
      if report.request_data[:before_callbacks]
        report.request_data[:before_callbacks].each {|c| c.call(*[report][0...c.arity]) }
      end

      @bugsnag.call(report)
    end
  end
end
