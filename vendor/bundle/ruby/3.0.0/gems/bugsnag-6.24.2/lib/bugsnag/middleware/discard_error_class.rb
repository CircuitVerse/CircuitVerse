module Bugsnag::Middleware
  ##
  # Determines if the exception should be ignored based on the configured
  # `discard_classes`
  class DiscardErrorClass
    ##
    # @param middleware [#call] The next middleware to call
    def initialize(middleware)
      @middleware = middleware
    end

    ##
    # @param report [Report]
    def call(report)
      should_discard = report.raw_exceptions.any? do |ex|
        report.configuration.discard_classes.any? do |to_ignore|
          case to_ignore
          when String then to_ignore == ex.class.name
          when Regexp then to_ignore =~ ex.class.name
          else false
          end
        end
      end

      report.ignore! if should_discard

      @middleware.call(report)
    end
  end
end
