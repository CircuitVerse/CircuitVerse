module Aws::SessionStore::DynamoDB
  class InvalidIDError < RuntimeError
    def initialize(msg = "Corrupt Session ID!")
      super
    end
  end
end
