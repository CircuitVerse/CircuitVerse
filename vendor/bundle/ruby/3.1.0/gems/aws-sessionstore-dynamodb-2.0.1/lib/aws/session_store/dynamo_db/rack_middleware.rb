require 'rack/session/abstract/id'
require 'openssl'
require 'aws-sdk-dynamodb'

module Aws::SessionStore::DynamoDB
  # This class is an ID based Session Store Rack Middleware
  # that uses a DynamoDB backend for session storage.
  class RackMiddleware < Rack::Session::Abstract::Persisted
    # @return [Configuration] An instance of Configuration that is used for
    #   this middleware.
    attr_reader :config

    # Initializes SessionStore middleware.
    #
    # @param app Rack application.
    # @option (see Configuration#initialize)
    # @raise [Aws::DynamoDB::Errors::ResourceNotFoundException] If valid table
    #   name is not provided.
    # @raise [Aws::SessionStore::DynamoDB::MissingSecretKey] If secret key is
    #   not provided.
    def initialize(app, options = {})
      super
      @config = Configuration.new(options)
      set_locking_strategy
    end

    private

    # Sets locking strategy for session handler
    #
    # @return [Locking::Null] If locking is not enabled.
    # @return [Locking::Pessimistic] If locking is enabled.
    def set_locking_strategy
      if @config.enable_locking
        @lock = Aws::SessionStore::DynamoDB::Locking::Pessimistic.new(@config)
      else
        @lock = Aws::SessionStore::DynamoDB::Locking::Null.new(@config)
      end
    end

    # Determines if the correct session table name is being used for
    # this application. Also tests existence of secret key.
    #
    # @raise [Aws::DynamoDB::Errors::ResourceNotFoundException] If wrong table
    #   name.
    def validate_config
      raise MissingSecretKeyError unless @config.secret_key
    end

    # Gets session data.
    def find_session(req, sid)
      validate_config
      case verify_hmac(sid)
      when nil
        set_new_session_properties(req.env)
      when false
        handle_error { raise InvalidIDError }
        set_new_session_properties(req.env)
      else
        data = @lock.get_session_data(req.env, sid)
        [sid, data || {}]
      end
    end

    def set_new_session_properties(env)
      env['dynamo_db.new_session'] = 'true'
      [generate_sid, {}]
    end

    # Sets the session in the database after packing data.
    #
    # @return [Hash] If session has been saved.
    # @return [false] If session has could not be saved.
    def write_session(req, sid, session, options)
      @lock.set_session_data(req.env, sid, session, options)
    end

    # Destroys session and removes session from database.
    #
    # @return [String] return a new session id or nil if options[:drop]
    def delete_session(req, sid, options)
      @lock.delete_session(req.env, sid)
      generate_sid unless options[:drop]
    end

    # Each database operation is placed in this rescue wrapper.
    # This wrapper will call the method, rescue any exceptions and then pass
    # exceptions to the configured session handler.
    def handle_error(env = nil, &block)
      begin
        yield
      rescue Aws::DynamoDB::Errors::Base,
             Aws::SessionStore::DynamoDB::InvalidIDError => e
        @config.error_handler.handle_error(e, env)
      end
    end

    # Generate HMAC hash based on MD5
    def generate_hmac(sid, secret)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest::MD5.new, secret, sid).strip()
    end

    # Generate sid with HMAC hash
    def generate_sid(secure = @sid_secure)
      sid = super(secure)
      sid = "#{generate_hmac(sid, @config.secret_key)}--" + sid
    end

    # Verify digest of HMACed hash
    #
    # @return [true] If the HMAC id has been verified.
    # @return [false] If the HMAC id has been corrupted.
    def verify_hmac(sid)
      return unless sid
      digest, ver_sid  = sid.split("--")
      return false unless ver_sid
      digest == generate_hmac(ver_sid, @config.secret_key)
    end
  end
end
