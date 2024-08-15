module Aws::SessionStore::DynamoDB
  class MissingSecretKeyError < RuntimeError
    def initialize(msg = "No secret key provided!")
      super
    end
  end
end
