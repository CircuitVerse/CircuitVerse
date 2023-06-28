module Aws
  module SessionStore
    module DynamoDB; end
  end
end

require 'aws/session_store/dynamo_db/configuration'
require 'aws/session_store/dynamo_db/invalid_id_error'
require 'aws/session_store/dynamo_db/missing_secret_key_error'
require 'aws/session_store/dynamo_db/lock_wait_timeout_error'
require 'aws/session_store/dynamo_db/errors/base_handler'
require 'aws/session_store/dynamo_db/errors/default_handler'
require 'aws/session_store/dynamo_db/garbage_collection'
require 'aws/session_store/dynamo_db/locking/base'
require 'aws/session_store/dynamo_db/locking/null'
require 'aws/session_store/dynamo_db/locking/pessimistic'
require 'aws/session_store/dynamo_db/rack_middleware'
require 'aws/session_store/dynamo_db/table'
require 'aws/session_store/dynamo_db/version'
