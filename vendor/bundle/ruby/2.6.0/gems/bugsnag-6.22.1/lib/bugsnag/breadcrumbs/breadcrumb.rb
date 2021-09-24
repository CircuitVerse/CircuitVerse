module Bugsnag::Breadcrumbs
  class Breadcrumb
    # @return [String] the breadcrumb name
    attr_accessor :name

    # @return [String] the breadcrumb type
    attr_accessor :type

    # @return [Hash, nil] metadata hash containing strings, numbers, or booleans, or nil
    attr_accessor :meta_data

    # @return [Boolean] set to `true` if the breadcrumb was automatically generated
    attr_reader :auto

    # @return [Time] a Time object referring to breadcrumb creation time
    attr_reader :timestamp

    ##
    # Creates a breadcrumb
    #
    # This will not have been validated, which must occur before this is attached to a report
    #
    # @api private
    #
    # @param name [String] the breadcrumb name
    # @param type [String] the breadcrumb type from Bugsnag::Breadcrumbs::VALID_BREADCRUMB_TYPES
    # @param meta_data [Hash, nil] a hash containing strings, numbers, or booleans, or nil
    # @param auto [Symbol] set to `:auto` if the breadcrumb is automatically generated
    def initialize(name, type, meta_data, auto)
      @should_ignore = false
      self.name = name
      self.type = type
      self.meta_data = meta_data

      # Use the symbol comparison to improve readability of breadcrumb creation
      @auto = auto == :auto

      # Store it as a timestamp for now
      @timestamp = Time.now.utc
    end

    ##
    # Flags the breadcrumb to be ignored
    #
    # Ignored breadcrumbs will not be attached to a report
    def ignore!
      @should_ignore = true
    end

    ##
    # Checks if the `ignore!` method has been called
    #
    # Ignored breadcrumbs will not be attached to a report
    #
    # @return [True] if `ignore!` has been called
    # @return [nil] if `ignore` has not been called
    def ignore?
      @should_ignore
    end

    ##
    # Outputs the breadcrumb data in a formatted hash
    #
    # These adhere to the breadcrumb format as defined in the Bugsnag error reporting API
    #
    # @return [Hash] Hash representation of the breadcrumb
    def to_h
      {
        :name => @name,
        :type => @type,
        :metaData => @meta_data,
        :timestamp => @timestamp.iso8601(3)
      }
    end
  end
end
