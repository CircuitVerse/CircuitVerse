module Bugsnag
  class Error
    # @return [String] the error's class name
    attr_accessor :error_class

    # @return [String] the error's message
    attr_accessor :error_message

    # @return [Hash] the error's processed stacktrace
    attr_reader :stacktrace

    # @return [String] the type of error (always "ruby")
    attr_accessor :type

    # @api private
    TYPE = "ruby".freeze

    def initialize(error_class, error_message, stacktrace)
      @error_class = error_class
      @error_message = error_message
      @stacktrace = stacktrace
      @type = TYPE
    end
  end
end
