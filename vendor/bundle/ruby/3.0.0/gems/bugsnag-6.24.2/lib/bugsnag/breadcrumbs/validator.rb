require 'bugsnag/breadcrumbs/breadcrumbs'

module Bugsnag::Breadcrumbs
  ##
  # Validates a given breadcrumb before it is stored
  class Validator
    ##
    # @param configuration [Bugsnag::Configuration] The current configuration
    def initialize(configuration)
      @configuration = configuration
    end

    ##
    # Validates a given breadcrumb.
    #
    # @param breadcrumb [Bugsnag::Breadcrumbs::Breadcrumb] the breadcrumb to be validated
    def validate(breadcrumb)
      # Check type is valid, set to manual otherwise
      unless Bugsnag::Breadcrumbs::VALID_BREADCRUMB_TYPES.include?(breadcrumb.type)
        @configuration.debug("Invalid type: #{breadcrumb.type} for breadcrumb: #{breadcrumb.name}, defaulting to #{Bugsnag::Breadcrumbs::MANUAL_BREADCRUMB_TYPE}")
        breadcrumb.type = Bugsnag::Breadcrumbs::MANUAL_BREADCRUMB_TYPE
      end

      # If auto is true, check type is in enabled_automatic_breadcrumb_types
      return unless breadcrumb.auto && !@configuration.enabled_automatic_breadcrumb_types.include?(breadcrumb.type)

      @configuration.debug("Automatic breadcrumb of type #{breadcrumb.type} ignored: #{breadcrumb.name}")
      breadcrumb.ignore!
    end
  end
end
