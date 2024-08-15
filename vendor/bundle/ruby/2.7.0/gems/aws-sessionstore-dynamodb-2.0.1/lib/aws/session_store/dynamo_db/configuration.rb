require 'yaml'
require 'aws-sdk-dynamodb'

module Aws::SessionStore::DynamoDB
  # This class provides a Configuration object for all DynamoDB transactions
  # by pulling configuration options from Runtime, a YAML file, the ENV and
  # default settings.
  #
  # == Environment Variables
  # The Configuration object can load default values from your environment. An example
  # of setting and environment variable is below:
  #
  #   export DYNAMO_DB_SESSION_TABLE_NAME='Sessions'
  #
  # == Handling Errors
  # There are two configurable options for error handling: :raise_errors and :error_handler.
  #
  # If you would like to use the Default Error Handler, you can decide to set :raise_errors
  # to true or false depending on whether you want all errors, regadless of class, to be raised
  # up the stack and essentially throw a 500.
  #
  # If you decide to use your own Error Handler. You may pass it in for the value of the key
  # :error_handler as a cofniguration object. You must implement the BaseErrorHandler class.
  # @see BaseHandler Interface for Error Handling for DynamoDB Session Store.
  #
  # == Locking Strategy
  # By default, locking is not implemented for the session store. You must trigger the
  # locking strategy through the configuration of the session store. Pessimistic locking,
  # in this case, means that only one read can be made on a session at once. While the session
  # is being read by the process with the lock, other processes may try to obtain a lock on
  # the same session but will be blocked. See the accessors with lock in their name for
  # how to configure the pessimistic locking strategy to your needs.
  #
  # == DynamoDB Specific Options
  # You may configure the table name and table hash key value of your session table with
  # the :table_name and :table_key options. You may also configure performance options for
  # your table with the :consistent_read, :read_capacity, write_capacity. For more information
  # about these configurations see CreateTable method for Amazon DynamoDB.
  #
  class Configuration

    # Default configuration options
    DEFAULTS = {
      :table_name => "sessions",
      :table_key => "session_id",
      :consistent_read => true,
      :read_capacity => 10,
      :write_capacity => 5,
      :raise_errors => false,
      # :max_age => 7*3600*24,
      # :max_stale => 3600*5,
      :enable_locking => false,
      :lock_expiry_time => 500,
      :lock_retry_delay => 500,
      :lock_max_wait_time => 1,
      :secret_key => nil
    }

    ### Feature options

    # @return [String] Session table name.
    attr_reader :table_name

    # @return [String] Session table hash key name.
    attr_reader :table_key

    # @return [true] If a strongly consistent read is used
    # @return [false] If an eventually consistent read is used.
    # See AWS DynamoDB documentation for table consistent_read for more
    # information on this setting.
    attr_reader :consistent_read

    # @return [Integer] Maximum number of reads consumed per second before
    #   DynamoDB returns a ThrottlingException. See AWS DynamoDB documentation
    #   for table read_capacity for more information on this setting.
    attr_reader :read_capacity

    # @return [Integer] Maximum number of writes consumed per second before
    #   DynamoDB returns a ThrottlingException. See AWS DynamoDB documentation
    #   for table write_capacity for more information on this setting.
    attr_reader :write_capacity

    # @return [true] All errors are raised up the stack when default ErrorHandler
    #   is used.
    # @return [false] Only specified errors are raised up the stack when default
    #   ErrorHandler is used.
    attr_reader :raise_errors

    # @return [Integer] Maximum number of seconds earlier
    #   from the current time that a session was created.
    attr_reader :max_age

    # @return [Integer] Maximum number of seconds
    #   before the current time that the session was last accessed.
    attr_reader :max_stale

    # @return [true] Pessimistic locking strategy will be implemented for
    #   all session accesses.
    # @return [false] No locking strategy will be implemented for
    #   all session accesses.
    attr_reader :enable_locking

    # @return [Integer] Time in milleseconds after which lock will expire.
    attr_reader :lock_expiry_time

    # @return [Integer] Time in milleseconds to wait before retrying to obtain
    #   lock once an attempt to obtain lock has been made and has failed.
    attr_reader :lock_retry_delay

    # @return [Integer] Maximum time in seconds to wait to acquire lock
    #   before giving up.
    attr_reader :lock_max_wait_time

    # @return [String] The secret key for HMAC encryption.
    attr_reader :secret_key

    # @return [String,Pathname]
    attr_reader :config_file

    ### Client and Error Handling options

    # @return [DynamoDB Client] DynamoDB client.
    attr_reader :dynamo_db_client

    # @return [Error Handler] An error handling object that handles all exceptions
    #   thrown during execution of the AWS DynamoDB Session Store Rack Middleware.
    #   For more information see the Handling Errors Section.
    attr_reader :error_handler

    # Provides configuration object that allows access to options defined
    # during Runtime, in a YAML file, in the ENV and by default.
    #
    # @option options [String] :table_name ("Sessions") Name of the session
    #   table.
    # @option options [String] :table_key ("id") The hash key of the sesison
    #   table.
    # @option options [Boolean] :consistent_read (true) If true, a strongly
    #   consistent read is used. If false, an eventually consistent read is
    #   used.
    # @option options [Integer] :read_capacity (10) The maximum number of
    #   strongly consistent reads consumed per second before
    #   DynamoDB raises a ThrottlingException. See AWS DynamoDB documentation
    #   for table read_capacity for more information on this setting.
    # @option options [Integer] :write_capacity (5) The maximum number of writes
    #   consumed per second before DynamoDB returns a ThrottlingException.
    #   See AWS DynamoDB documentation for table write_capacity for more
    #   information on this setting.
    # @option options [DynamoDB Client] :dynamo_db_client
    #   (Aws::DynamoDB::Client) DynamoDB client used to perform database
    #   operations inside of middleware application.
    # @option options [Boolean] :raise_errors (false) If true, all errors are
    #   raised up the stack when default ErrorHandler. If false, Only specified
    #   errors are raised up the stack when default ErrorHandler is used.
    # @option options [Error Handler] :error_handler (DefaultErrorHandler)
    #   An error handling object that handles all exceptions thrown during
    #   execution of the AWS DynamoDB Session Store Rack Middleware.
    #   For more information see the Handling Errors Section.
    # @option options [Integer] :max_age (nil) Maximum number of seconds earlier
    #   from the current time that a session was created.
    # @option options [Integer] :max_stale (nil) Maximum number of seconds
    #   before current time that session was last accessed.
    # @option options [String] :secret_key (nil) Secret key for HMAC encription.
    # @option options [Integer] :enable_locking (false) If true, a pessimistic
    #   locking strategy will be implemented for all session accesses.
    #   If false, no locking strategy will be implemented for all session
    #   accesses.
    # @option options [Integer] :lock_expiry_time (500) Time in milliseconds
    #   after which lock expires on session.
    # @option options [Integer] :lock_retry_delay (500) Time in milleseconds to
    #   wait before retrying to obtain lock once an attempt to obtain lock
    #   has been made and has failed.
    # @option options [Integer] :lock_max_wait_time (500) Maximum time
    #   in seconds to wait to acquire lock before giving up.
    # @option options [String] :secret_key (SecureRandom.hex(64))
    #   Secret key for HMAC encription.
    def initialize(options = {})
      @options = default_options.merge(
        env_options.merge(
          file_options(options).merge(symbolize_keys(options))
        )
      )
      @options = client_error.merge(@options)
      set_attributes(@options)
    end

    # @return [Hash] The merged configuration hash.
    def to_hash
      @options.dup
    end

    private

    # @return [Hash] DDB client.
    def gen_dynamo_db_client
      client_opts = { user_agent_suffix: " aws-sessionstore/#{VERSION}" }
      client = Aws::DynamoDB::Client
      dynamo_db_client = @options[:dynamo_db_client] || client.new(client_opts)
      {:dynamo_db_client => dynamo_db_client}
    end

    # @return [Hash] Default Error Handler
    def gen_error_handler
      default_handler = Aws::SessionStore::DynamoDB::Errors::DefaultHandler
      error_handler = @options[:error_handler] ||
                            default_handler.new(@options[:raise_errors])
      {:error_handler => error_handler}
    end

    # @return [Hash] Client and error objects in hash.
    def client_error
      gen_error_handler.merge(gen_dynamo_db_client)
    end

    # @return [Hash] Default Session table options.
    def default_options
      DEFAULTS
    end

    # @return [Hash] Environment options that are useful for Session Handler.
    def env_options
      default_options.keys.inject({}) do |opts, opt_name|
        env_var = "DYNAMO_DB_SESSION_#{opt_name.to_s.upcase}"
        opts[opt_name] = ENV[env_var] if ENV.key?(env_var)
        opts
      end
    end

    # @return [Hash] File options.
    def file_options(options = {})
      file_path = config_file_path(options)
      if file_path
        load_from_file(file_path)
      else
        {}
      end
    end

    # Load options from YAML file
    def load_from_file(file_path)
      require "erb"
      opts = YAML.load(ERB.new(File.read(file_path)).result) || {}
      symbolize_keys(opts)
    end

    # @return [String] Configuration path found in environment or YAML file.
    def config_file_path(options)
      options[:config_file] || ENV["DYNAMO_DB_SESSION_CONFIG_FILE"]
    end

    # Set accessible attributes after merged options.
    def set_attributes(options)
      @options.keys.each do |opt_name|
        instance_variable_set("@#{opt_name}", options[opt_name])
      end
    end

    # @return [Hash] Hash with all symbolized keys.
    def symbolize_keys(options)
      options.inject({}) do |opts, (opt_name, opt_value)|
        opts[opt_name.to_sym] = opt_value
        opts
      end
    end
  end
end
