module Aws::SessionStore::DynamoDB::Errors
  # BaseErrorHandler provides an interface for error handlers
  # that can be passed in to {Aws::SessionStore::DynamoDB::RackMiddleware}.
  # Each error handler must implement a handle_error method.
  #
  # @example Sample ErrorHandler class
  #   class MyErrorHandler < BaseErrorHandler
  #    # Handles error passed in
  #    def handle_error(e, env = {})
  #      File.open(path_to_file, 'w') {|f| f.write(e.message) }
  #      false
  #    end
  #   end
  class BaseHandler
    # An error and an environment (optionally) will be passed in to
    # this method and it will determine how to deal
    # with the error.
    # Must return false if you have handled the error but are not reraising the
    # error up the stack.
    # You may reraise the error passed.
    #
    # @param [Aws::DynamoDB::Errors::Base] error error passed in from
    #  Aws::SessionStore::DynamoDB::RackMiddleware.
    # @param [Rack::Request::Environment,nil] env Rack environment
    # @return [false] If exception was handled and will not reraise exception.
    # @raise [Aws::DynamoDB::Errors] If error has be reraised.
    def handle_error(error, env = {})
      raise NotImplementedError
    end
  end
end
