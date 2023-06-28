module Aws::SessionStore::DynamoDB::Locking
  # This class gets and sets sessions
  # without a locking strategy.
  class Null < Aws::SessionStore::DynamoDB::Locking::Base
    # Retrieve session if it exists from the database by id.
    # Unpack the data once retrieved from the database.
    def get_session_data(env, sid)
      handle_error(env) do
        result = @config.dynamo_db_client.get_item(get_session_opts(sid))
        extract_data(env, result)
      end
    end

    # @return [Hash] Options for getting session.
    def get_session_opts(sid)
      merge_all(table_opts(sid), attr_opts)
    end

    # @return [String] Session data.
    def extract_data(env, result = nil)
      env['rack.initial_data'] = result[:item]["data"] if result[:item]
      unpack_data(result[:item]["data"]) if result[:item]
    end

  end
end
