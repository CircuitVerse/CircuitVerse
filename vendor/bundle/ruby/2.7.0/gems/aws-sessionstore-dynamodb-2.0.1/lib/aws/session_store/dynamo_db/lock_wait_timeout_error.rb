module Aws::SessionStore::DynamoDB
  class LockWaitTimeoutError < RuntimeError
    def initialize(msg = 'Maximum time spent to acquire lock has been exceeded!')
      super
    end
  end
end
