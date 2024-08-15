module Aws::SessionStore::DynamoDB::Errors
  # This class handles errors raised from DynamoDB.
  class DefaultHandler < Aws::SessionStore::DynamoDB::Errors::BaseHandler
    # Array of errors that will always be passed up the Rack stack.
    HARD_ERRORS = [
      Aws::DynamoDB::Errors::ResourceNotFoundException,
      Aws::DynamoDB::Errors::ConditionalCheckFailedException,
      Aws::SessionStore::DynamoDB::MissingSecretKeyError,
      Aws::SessionStore::DynamoDB::LockWaitTimeoutError
    ]

    # Determines behavior of DefaultErrorHandler
    # @param [true] raise_errors Pass all errors up the Rack stack.
    def initialize(raise_errors)
      @raise_errors = raise_errors
    end

    # Raises {HARD_ERRORS} up the Rack stack.
    # Places all other errors in Racks error stream.
    def handle_error(error, env = {})
      if HARD_ERRORS.include?(error.class) || @raise_errors
        raise error
      else
        store_error(error, env)
        false
      end
    end

    # Sends error to error stream
    def store_error(error, env = {})
      env["rack.errors"].puts(errors_string(error)) if env
    end

    # Returns string to be placed in error stream
    def errors_string(error)
      str = []
      str << "Exception occurred: #{error.message}"
      str << "Stack trace:"
      str += error.backtrace.map {|l| "  " + l }
      str.join("\n")
    end
  end
end
