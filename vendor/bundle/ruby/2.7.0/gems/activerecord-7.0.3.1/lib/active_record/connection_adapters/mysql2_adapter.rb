# frozen_string_literal: true

require "active_record/connection_adapters/abstract_mysql_adapter"
require "active_record/connection_adapters/mysql/database_statements"

gem "mysql2", "~> 0.5"
require "mysql2"

module ActiveRecord
  module ConnectionHandling # :nodoc:
    # Establishes a connection to the database that's used by all Active Record objects.
    def mysql2_connection(config)
      config = config.symbolize_keys
      config[:flags] ||= 0

      if config[:flags].kind_of? Array
        config[:flags].push "FOUND_ROWS"
      else
        config[:flags] |= Mysql2::Client::FOUND_ROWS
      end

      ConnectionAdapters::Mysql2Adapter.new(
        ConnectionAdapters::Mysql2Adapter.new_client(config),
        logger,
        nil,
        config,
      )
    end
  end

  module ConnectionAdapters
    class Mysql2Adapter < AbstractMysqlAdapter
      ER_BAD_DB_ERROR        = 1049
      ER_ACCESS_DENIED_ERROR = 1045
      ER_CONN_HOST_ERROR     = 2003
      ER_UNKNOWN_HOST_ERROR  = 2005

      ADAPTER_NAME = "Mysql2"

      include MySQL::DatabaseStatements

      class << self
        def new_client(config)
          Mysql2::Client.new(config)
        rescue Mysql2::Error => error
          if error.error_number == ConnectionAdapters::Mysql2Adapter::ER_BAD_DB_ERROR
            raise ActiveRecord::NoDatabaseError.db_error(config[:database])
          elsif error.error_number == ConnectionAdapters::Mysql2Adapter::ER_ACCESS_DENIED_ERROR
            raise ActiveRecord::DatabaseConnectionError.username_error(config[:username])
          elsif [ConnectionAdapters::Mysql2Adapter::ER_CONN_HOST_ERROR, ConnectionAdapters::Mysql2Adapter::ER_UNKNOWN_HOST_ERROR].include?(error.error_number)
            raise ActiveRecord::DatabaseConnectionError.hostname_error(config[:host])
          else
            raise ActiveRecord::ConnectionNotEstablished, error.message
          end
        end
      end

      def initialize(connection, logger, connection_options, config)
        superclass_config = config.reverse_merge(prepared_statements: false)
        super(connection, logger, connection_options, superclass_config)
        configure_connection
      end

      def self.database_exists?(config)
        !!ActiveRecord::Base.mysql2_connection(config)
      rescue ActiveRecord::NoDatabaseError
        false
      end

      def supports_json?
        !mariadb? && database_version >= "5.7.8"
      end

      def supports_comments?
        true
      end

      def supports_comments_in_create?
        true
      end

      def supports_savepoints?
        true
      end

      def supports_lazy_transactions?
        true
      end

      # HELPER METHODS ===========================================

      def each_hash(result, &block) # :nodoc:
        if block_given?
          result.each(as: :hash, symbolize_keys: true, &block)
        else
          to_enum(:each_hash, result)
        end
      end

      def error_number(exception)
        exception.error_number if exception.respond_to?(:error_number)
      end

      #--
      # QUOTING ==================================================
      #++

      def quote_string(string)
        @connection.escape(string)
      rescue Mysql2::Error => error
        raise translate_exception(error, message: error.message, sql: "<escape>", binds: [])
      end

      #--
      # CONNECTION MANAGEMENT ====================================
      #++

      def active?
        @connection.ping
      end

      def reconnect!
        super
        disconnect!
        connect
      end
      alias :reset! :reconnect!

      # Disconnects from the database if already connected.
      # Otherwise, this method does nothing.
      def disconnect!
        super
        @connection.close
      end

      def discard! # :nodoc:
        super
        @connection.automatic_close = false
        @connection = nil
      end

      private
        def connect
          @connection = self.class.new_client(@config)
          configure_connection
        end

        def configure_connection
          @connection.query_options[:as] = :array
          super
        end

        def full_version
          schema_cache.database_version.full_version_string
        end

        def get_full_version
          @connection.server_info[:version]
        end

        def translate_exception(exception, message:, sql:, binds:)
          if exception.is_a?(Mysql2::Error::TimeoutError) && !exception.error_number
            ActiveRecord::AdapterTimeout.new(message, sql: sql, binds: binds)
          else
            super
          end
        end
    end
  end
end
