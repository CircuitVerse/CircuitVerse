module Bugsnag::Middleware
  ##
  # Adds breadcrumbs to the report
  class Breadcrumbs
    ##
    # @param next_callable [#call] the next callable middleware
    def initialize(next_callable)
      @next = next_callable
    end

    ##
    # Execute this middleware
    #
    # @param report [Bugsnag::Report] the report being iterated over
    def call(report)
      breadcrumbs = report.configuration.breadcrumbs.to_a
      report.breadcrumbs = breadcrumbs unless breadcrumbs.empty?
      @next.call(report)
    end
  end
end
