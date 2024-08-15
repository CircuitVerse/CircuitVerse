module Aws::SessionStore::DynamoDB::Locking
  # This class provides a framework for implementing
  # locking strategies.
  class Base

    # Creates configuration object.
    def initialize(cfg)
      @config = cfg
    end

    # Updates session in database
    def set_session_data(env, sid, session, options = {})
      return false if session.empty?
      packed_session = pack_data(session)
      handle_error(env) do
        save_opts = update_opts(env, sid, packed_session, options)
        @config.dynamo_db_client.update_item(save_opts)
        sid
      end
    end

    # Packs session data.
    def pack_data(data)
      [Marshal.dump(data)].pack("m*")
    end

    # Gets session data.
    def get_session_data(env, sid)
      raise NotImplementedError
    end

    # Deletes session based on id
    def delete_session(env, sid)
      handle_error(env) do
        @config.dynamo_db_client.delete_item(delete_opts(sid))
      end
    end

    # Each database operation is placed in this rescue wrapper.
    # This wrapper will call the method, rescue any exceptions and then pass
    # exceptions to the configured error handler.
    def handle_error(env = nil, &block)
      begin
        yield
      rescue Aws::DynamoDB::Errors::ServiceError => e
        @config.error_handler.handle_error(e, env)
      end
    end

    private

    # @return [Hash] Options for deleting session.
    def delete_opts(sid)
      table_opts(sid)
    end

    # @return [Hash] Options for updating item in Session table.
    def update_opts(env, sid, session, options = {})
      if env['dynamo_db.new_session']
        updt_options = save_new_opts(env, sid, session)
      else
        updt_options = save_exists_opts(env, sid, session, options)
      end
      updt_options
    end

    # @return [Hash] Options for saving a new session in database.
    def save_new_opts(env, sid, session)
      attribute_opts = attr_updts(env, session, created_attr)
      merge_all(table_opts(sid), attribute_opts)
    end

    # @return [Hash] Options for saving an existing sesison in the database.
    def save_exists_opts(env, sid, session, options = {})
      add_attr = options[:add_attrs] || {}
      expected = options[:expect_attr] || {}
      attribute_opts = merge_all(attr_updts(env, session, add_attr), expected)
      merge_all(table_opts(sid), attribute_opts)
    end

    # Unmarshal the data.
    def unpack_data(packed_data)
      Marshal.load(packed_data.unpack("m*").first)
    end

    # Table options for client.
    def table_opts(sid)
      {
        :table_name => @config.table_name,
        :key => { @config.table_key => sid }
      }
    end

    # Attributes to update via client.
    def attr_updts(env, session, add_attrs = {})
      data = data_unchanged?(env, session) ? {} : data_attr(session)
      {
        attribute_updates: merge_all(updated_attr, data, add_attrs, expire_attr),
        return_values: 'UPDATED_NEW'
      }
    end

    # Update client with current time attribute.
    def updated_at
      { :value => "#{(Time.now).to_f}", :action  => "PUT" }
    end

    # Attribute for creation of session.
    def created_attr
      { "created_at" => updated_at }
    end

    # Update client with current time + max_stale.
    def expire_at
      max_stale = @config.max_stale || 0
      { value: (Time.now + max_stale).to_i, action: 'PUT' }
    end

    # Attribute for TTL expiration of session.
    def expire_attr
      { 'expire_at' => expire_at }
    end

    # Attribute for updating session.
    def updated_attr
      {
        "updated_at" => updated_at
      }
    end

    def data_attr(session)
       { "data" => {:value => session, :action  => "PUT"} }
    end

    # Determine if data has been manipulated
    def data_unchanged?(env, session)
      return false unless env['rack.initial_data']
      env['rack.initial_data'] == session
    end

    # Expected attributes
    def expected_attributes(sid)
      { :expected => { @config.table_key => {:value => sid, :exists => true} } }
    end

    # Attributes to be retrieved via client
    def attr_opts
      {:attributes_to_get => ["data"],
      :consistent_read => @config.consistent_read}
    end

    # @return [Hash] merged hash of all hashes passed in.
    def merge_all(*hashes)
      new_hash = {}
      hashes.each{|hash| new_hash.merge!(hash)}
      new_hash
    end
  end
end
