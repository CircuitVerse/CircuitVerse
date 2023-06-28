module Aws::SessionStore::DynamoDB::Locking
  # This class implements a pessimistic locking strategy for the
  # DynamoDB session handler. Sessions obtain an exclusive lock
  # for reads that is only released when the session is saved.
  class Pessimistic < Aws::SessionStore::DynamoDB::Locking::Base
    # Saves the session.
    def set_session_data(env, sid, session, options = {})
      super(env, sid, session, set_lock_options(env, options))
    end

    # Gets session from database and places a lock on the session
    # while you are reading from the database.
    def get_session_data(env, sid)
      handle_error(env) do
        get_session_with_lock(env, sid)
      end
    end

    private

    # Get session with implemented locking strategy.
    def get_session_with_lock(env, sid)
      expires_at = nil
      result = nil
      max_attempt_date = Time.now.to_f + @config.lock_max_wait_time
      while result.nil?
        exceeded_wait_time?(max_attempt_date)
        begin
          result = attempt_set_lock(sid)
        rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
          expires_at ||= get_expire_date(sid)
          next if expires_at.nil?
          result = bust_lock(sid, expires_at)
          wait_to_retry(result)
        end
      end
      get_data(env, result)
    end

    # Determine if session has waited too long to obtain lock.
    #
    # @raise [Error] When time for attempting to get lock has
    #   been exceeded.
    def exceeded_wait_time?(max_attempt_date)
      lock_error = Aws::SessionStore::DynamoDB::LockWaitTimeoutError
      raise lock_error if Time.now.to_f > max_attempt_date
    end

    # @return [Hash] Options hash for placing a lock on a session.
    def get_lock_time_opts(sid)
      merge_all(table_opts(sid), lock_opts)
    end

    # @return [Time] Time stamp for which the session was locked.
    def lock_time(sid)
      result = @config.dynamo_db_client.get_item(get_lock_time_opts(sid))
      (result[:item]["locked_at"]).to_f if result[:item]["locked_at"]
    end

    # @return [String] Session data.
    def get_data(env, result)
      lock_time = result[:attributes]["locked_at"]
      env["locked_at"] = (lock_time).to_f
      env['rack.initial_data'] = result[:item]["data"] if result.members.include? :item
      unpack_data(result[:attributes]["data"])
    end

    # Attempt to bust the lock if the expiration date has expired.
    def bust_lock(sid, expires_at)
      if expires_at < Time.now.to_f
        @config.dynamo_db_client.update_item(obtain_lock_opts(sid))
      end
    end

    # @return [Hash] Options hash for obtaining the lock.
    def obtain_lock_opts(sid, add_opt = {})
      merge_all(table_opts(sid), lock_attr, add_opt)
    end

    # Sleep for given time period if the session is currently locked.
    def wait_to_retry(result)
      sleep(0.001 * @config.lock_retry_delay) if result.nil?
    end

    # Get the expiration date for the session
    def get_expire_date(sid)
      lock_date = lock_time(sid)
      lock_date + (0.001 * @config.lock_expiry_time) if lock_date
    end

    # Attempt to place a lock on the session.
    def attempt_set_lock(sid)
      @config.dynamo_db_client.update_item(obtain_lock_opts(sid, lock_expect))
    end

    # Lock attribute - time stamp of when session was locked.
    def lock_attr
      {
        :attribute_updates => {"locked_at" => updated_at},
        :return_values => "ALL_NEW"
      }
    end

    # Time in which session was updated.
    def updated_at
      { :value => "#{(Time.now).to_f}", :action  => "PUT" }
    end

    # Attributes for locking.
    def add_lock_attrs(env)
      {
        :add_attrs => add_attr, :expect_attr => expect_lock_time(env)
      }
    end

    # Lock options for setting lock.
    def set_lock_options(env, options = {})
      merge_all(options, add_lock_attrs(env))
    end

    # Lock expectation.
    def lock_expect
      { :expected => { "locked_at" => { :exists => false } } }
    end

    # Option to delete lock.
    def add_attr
      { "locked_at" => {:action => "DELETE"} }
    end

    # Expectation of when lock was set.
    def expect_lock_time(env)
      { :expected => {"locked_at" => {
        :value => "#{env["locked_at"]}", :exists => true}} }
    end

    # Attributes to be retrieved via client
    def lock_opts
      {:attributes_to_get => ["locked_at"],
      :consistent_read => @config.consistent_read}
    end

  end
end
