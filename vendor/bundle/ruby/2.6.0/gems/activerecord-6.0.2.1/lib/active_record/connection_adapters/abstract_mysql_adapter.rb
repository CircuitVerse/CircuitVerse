# frozen_string_literal: true

require "active_record/connection_adapters/abstract_adapter"
require "active_record/connection_adapters/statement_pool"
require "active_record/connection_adapters/mysql/column"
require "active_record/connection_adapters/mysql/explain_pretty_printer"
require "active_record/connection_adapters/mysql/quoting"
require "active_record/connection_adapters/mysql/schema_creation"
require "active_record/connection_adapters/mysql/schema_definitions"
require "active_record/connection_adapters/mysql/schema_dumper"
require "active_record/connection_adapters/mysql/schema_statements"
require "active_record/connection_adapters/mysql/type_metadata"

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter < AbstractAdapter
      include MySQL::Quoting
      include MySQL::SchemaStatements

      ##
      # :singleton-method:
      # By default, the Mysql2Adapter will consider all columns of type <tt>tinyint(1)</tt>
      # as boolean. If you wish to disable this emulation you can add the following line
      # to your application.rb file:
      #
      #   ActiveRecord::ConnectionAdapters::Mysql2Adapter.emulate_booleans = false
      class_attribute :emulate_booleans, default: true

      NATIVE_DATABASE_TYPES = {
        primary_key: "bigint auto_increment PRIMARY KEY",
        string:      { name: "varchar", limit: 255 },
        text:        { name: "text" },
        integer:     { name: "int", limit: 4 },
        float:       { name: "float", limit: 24 },
        decimal:     { name: "decimal" },
        datetime:    { name: "datetime" },
        timestamp:   { name: "timestamp" },
        time:        { name: "time" },
        date:        { name: "date" },
        binary:      { name: "blob" },
        blob:        { name: "blob" },
        boolean:     { name: "tinyint", limit: 1 },
        json:        { name: "json" },
      }

      class StatementPool < ConnectionAdapters::StatementPool # :nodoc:
        private

          def dealloc(stmt)
            stmt.close
          end
      end

      def initialize(connection, logger, connection_options, config)
        super(connection, logger, config)
      end

      def get_database_version #:nodoc:
        full_version_string = get_full_version
        version_string = version_string(full_version_string)
        Version.new(version_string, full_version_string)
      end

      def mariadb? # :nodoc:
        /mariadb/i.match?(full_version)
      end

      def supports_bulk_alter?
        true
      end

      def supports_index_sort_order?
        !mariadb? && database_version >= "8.0.1"
      end

      def supports_expression_index?
        !mariadb? && database_version >= "8.0.13"
      end

      def supports_transaction_isolation?
        true
      end

      def supports_explain?
        true
      end

      def supports_indexes_in_create?
        true
      end

      def supports_foreign_keys?
        true
      end

      def supports_views?
        true
      end

      def supports_datetime_with_precision?
        mariadb? || database_version >= "5.6.4"
      end

      def supports_virtual_columns?
        mariadb? || database_version >= "5.7.5"
      end

      # See https://dev.mysql.com/doc/refman/8.0/en/optimizer-hints.html for more details.
      def supports_optimizer_hints?
        !mariadb? && database_version >= "5.7.7"
      end

      def supports_common_table_expressions?
        if mariadb?
          database_version >= "10.2.1"
        else
          database_version >= "8.0.1"
        end
      end

      def supports_advisory_locks?
        true
      end

      def supports_insert_on_duplicate_skip?
        true
      end

      def supports_insert_on_duplicate_update?
        true
      end

      def get_advisory_lock(lock_name, timeout = 0) # :nodoc:
        query_value("SELECT GET_LOCK(#{quote(lock_name.to_s)}, #{timeout})") == 1
      end

      def release_advisory_lock(lock_name) # :nodoc:
        query_value("SELECT RELEASE_LOCK(#{quote(lock_name.to_s)})") == 1
      end

      def native_database_types
        NATIVE_DATABASE_TYPES
      end

      def index_algorithms
        { default: +"ALGORITHM = DEFAULT", copy: +"ALGORITHM = COPY", inplace: +"ALGORITHM = INPLACE" }
      end

      # HELPER METHODS ===========================================

      # The two drivers have slightly different ways of yielding hashes of results, so
      # this method must be implemented to provide a uniform interface.
      def each_hash(result) # :nodoc:
        raise NotImplementedError
      end

      # Must return the MySQL error number from the exception, if the exception has an
      # error number.
      def error_number(exception) # :nodoc:
        raise NotImplementedError
      end

      # REFERENTIAL INTEGRITY ====================================

      def disable_referential_integrity #:nodoc:
        old = query_value("SELECT @@FOREIGN_KEY_CHECKS")

        begin
          update("SET FOREIGN_KEY_CHECKS = 0")
          yield
        ensure
          update("SET FOREIGN_KEY_CHECKS = #{old}")
        end
      end

      # CONNECTION MANAGEMENT ====================================

      def clear_cache! # :nodoc:
        reload_type_map
        super
      end

      #--
      # DATABASE STATEMENTS ======================================
      #++

      def explain(arel, binds = [])
        sql     = "EXPLAIN #{to_sql(arel, binds)}"
        start   = Concurrent.monotonic_time
        result  = exec_query(sql, "EXPLAIN", binds)
        elapsed = Concurrent.monotonic_time - start

        MySQL::ExplainPrettyPrinter.new.pp(result, elapsed)
      end

      # Executes the SQL statement in the context of this connection.
      def execute(sql, name = nil)
        materialize_transactions

        log(sql, name) do
          ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
            @connection.query(sql)
          end
        end
      end

      # Mysql2Adapter doesn't have to free a result after using it, but we use this method
      # to write stuff in an abstract way without concerning ourselves about whether it
      # needs to be explicitly freed or not.
      def execute_and_free(sql, name = nil) # :nodoc:
        yield execute(sql, name)
      end

      def begin_db_transaction
        execute "BEGIN"
      end

      def begin_isolated_db_transaction(isolation)
        execute "SET TRANSACTION ISOLATION LEVEL #{transaction_isolation_levels.fetch(isolation)}"
        begin_db_transaction
      end

      def commit_db_transaction #:nodoc:
        execute "COMMIT"
      end

      def exec_rollback_db_transaction #:nodoc:
        execute "ROLLBACK"
      end

      def empty_insert_statement_value(primary_key = nil)
        "VALUES ()"
      end

      # SCHEMA STATEMENTS ========================================

      # Drops the database specified on the +name+ attribute
      # and creates it again using the provided +options+.
      def recreate_database(name, options = {})
        drop_database(name)
        sql = create_database(name, options)
        reconnect!
        sql
      end

      # Create a new MySQL database with optional <tt>:charset</tt> and <tt>:collation</tt>.
      # Charset defaults to utf8mb4.
      #
      # Example:
      #   create_database 'charset_test', charset: 'latin1', collation: 'latin1_bin'
      #   create_database 'matt_development'
      #   create_database 'matt_development', charset: :big5
      def create_database(name, options = {})
        if options[:collation]
          execute "CREATE DATABASE #{quote_table_name(name)} DEFAULT COLLATE #{quote_table_name(options[:collation])}"
        elsif options[:charset]
          execute "CREATE DATABASE #{quote_table_name(name)} DEFAULT CHARACTER SET #{quote_table_name(options[:charset])}"
        elsif row_format_dynamic_by_default?
          execute "CREATE DATABASE #{quote_table_name(name)} DEFAULT CHARACTER SET `utf8mb4`"
        else
          raise "Configure a supported :charset and ensure innodb_large_prefix is enabled to support indexes on varchar(255) string columns."
        end
      end

      # Drops a MySQL database.
      #
      # Example:
      #   drop_database('sebastian_development')
      def drop_database(name) #:nodoc:
        execute "DROP DATABASE IF EXISTS #{quote_table_name(name)}"
      end

      def current_database
        query_value("SELECT database()", "SCHEMA")
      end

      # Returns the database character set.
      def charset
        show_variable "character_set_database"
      end

      # Returns the database collation strategy.
      def collation
        show_variable "collation_database"
      end

      def table_comment(table_name) # :nodoc:
        scope = quoted_scope(table_name)

        query_value(<<~SQL, "SCHEMA").presence
          SELECT table_comment
          FROM information_schema.tables
          WHERE table_schema = #{scope[:schema]}
            AND table_name = #{scope[:name]}
        SQL
      end

      def change_table_comment(table_name, comment_or_changes) # :nodoc:
        comment = extract_new_comment_value(comment_or_changes)
        comment = "" if comment.nil?
        execute("ALTER TABLE #{quote_table_name(table_name)} COMMENT #{quote(comment)}")
      end

      # Renames a table.
      #
      # Example:
      #   rename_table('octopuses', 'octopi')
      def rename_table(table_name, new_name)
        execute "RENAME TABLE #{quote_table_name(table_name)} TO #{quote_table_name(new_name)}"
        rename_table_indexes(table_name, new_name)
      end

      # Drops a table from the database.
      #
      # [<tt>:force</tt>]
      #   Set to +:cascade+ to drop dependent objects as well.
      #   Defaults to false.
      # [<tt>:if_exists</tt>]
      #   Set to +true+ to only drop the table if it exists.
      #   Defaults to false.
      # [<tt>:temporary</tt>]
      #   Set to +true+ to drop temporary table.
      #   Defaults to false.
      #
      # Although this command ignores most +options+ and the block if one is given,
      # it can be helpful to provide these in a migration's +change+ method so it can be reverted.
      # In that case, +options+ and the block will be used by create_table.
      def drop_table(table_name, options = {})
        execute "DROP#{' TEMPORARY' if options[:temporary]} TABLE#{' IF EXISTS' if options[:if_exists]} #{quote_table_name(table_name)}#{' CASCADE' if options[:force] == :cascade}"
      end

      def rename_index(table_name, old_name, new_name)
        if supports_rename_index?
          validate_index_length!(table_name, new_name)

          execute "ALTER TABLE #{quote_table_name(table_name)} RENAME INDEX #{quote_table_name(old_name)} TO #{quote_table_name(new_name)}"
        else
          super
        end
      end

      def change_column_default(table_name, column_name, default_or_changes) #:nodoc:
        default = extract_new_default_value(default_or_changes)
        change_column table_name, column_name, nil, default: default
      end

      def change_column_null(table_name, column_name, null, default = nil) #:nodoc:
        unless null || default.nil?
          execute("UPDATE #{quote_table_name(table_name)} SET #{quote_column_name(column_name)}=#{quote(default)} WHERE #{quote_column_name(column_name)} IS NULL")
        end

        change_column table_name, column_name, nil, null: null
      end

      def change_column_comment(table_name, column_name, comment_or_changes) # :nodoc:
        comment = extract_new_comment_value(comment_or_changes)
        change_column table_name, column_name, nil, comment: comment
      end

      def change_column(table_name, column_name, type, options = {}) #:nodoc:
        execute("ALTER TABLE #{quote_table_name(table_name)} #{change_column_for_alter(table_name, column_name, type, options)}")
      end

      def rename_column(table_name, column_name, new_column_name) #:nodoc:
        execute("ALTER TABLE #{quote_table_name(table_name)} #{rename_column_for_alter(table_name, column_name, new_column_name)}")
        rename_column_indexes(table_name, column_name, new_column_name)
      end

      def add_index(table_name, column_name, options = {}) #:nodoc:
        index_name, index_type, index_columns, _, index_algorithm, index_using, comment = add_index_options(table_name, column_name, options)
        sql = +"CREATE #{index_type} INDEX #{quote_column_name(index_name)} #{index_using} ON #{quote_table_name(table_name)} (#{index_columns}) #{index_algorithm}"
        execute add_sql_comment!(sql, comment)
      end

      def add_sql_comment!(sql, comment) # :nodoc:
        sql << " COMMENT #{quote(comment)}" if comment.present?
        sql
      end

      def foreign_keys(table_name)
        raise ArgumentError unless table_name.present?

        scope = quoted_scope(table_name)

        fk_info = exec_query(<<~SQL, "SCHEMA")
          SELECT fk.referenced_table_name AS 'to_table',
                 fk.referenced_column_name AS 'primary_key',
                 fk.column_name AS 'column',
                 fk.constraint_name AS 'name',
                 rc.update_rule AS 'on_update',
                 rc.delete_rule AS 'on_delete'
          FROM information_schema.referential_constraints rc
          JOIN information_schema.key_column_usage fk
          USING (constraint_schema, constraint_name)
          WHERE fk.referenced_column_name IS NOT NULL
            AND fk.table_schema = #{scope[:schema]}
            AND fk.table_name = #{scope[:name]}
            AND rc.constraint_schema = #{scope[:schema]}
            AND rc.table_name = #{scope[:name]}
        SQL

        fk_info.map do |row|
          options = {
            column: row["column"],
            name: row["name"],
            primary_key: row["primary_key"]
          }

          options[:on_update] = extract_foreign_key_action(row["on_update"])
          options[:on_delete] = extract_foreign_key_action(row["on_delete"])

          ForeignKeyDefinition.new(table_name, row["to_table"], options)
        end
      end

      def table_options(table_name) # :nodoc:
        table_options = {}

        create_table_info = create_table_info(table_name)

        # strip create_definitions and partition_options
        raw_table_options = create_table_info.sub(/\A.*\n\) /m, "").sub(/\n\/\*!.*\*\/\n\z/m, "").strip

        # strip AUTO_INCREMENT
        raw_table_options.sub!(/(ENGINE=\w+)(?: AUTO_INCREMENT=\d+)/, '\1')

        table_options[:options] = raw_table_options

        # strip COMMENT
        if raw_table_options.sub!(/ COMMENT='.+'/, "")
          table_options[:comment] = table_comment(table_name)
        end

        table_options
      end

      # SHOW VARIABLES LIKE 'name'
      def show_variable(name)
        query_value("SELECT @@#{name}", "SCHEMA")
      rescue ActiveRecord::StatementInvalid
        nil
      end

      def primary_keys(table_name) # :nodoc:
        raise ArgumentError unless table_name.present?

        scope = quoted_scope(table_name)

        query_values(<<~SQL, "SCHEMA")
          SELECT column_name
          FROM information_schema.statistics
          WHERE index_name = 'PRIMARY'
            AND table_schema = #{scope[:schema]}
            AND table_name = #{scope[:name]}
          ORDER BY seq_in_index
        SQL
      end

      def default_uniqueness_comparison(attribute, value, klass) # :nodoc:
        column = column_for_attribute(attribute)

        if column.collation && !column.case_sensitive? && !value.nil?
          ActiveSupport::Deprecation.warn(<<~MSG.squish)
            Uniqueness validator will no longer enforce case sensitive comparison in Rails 6.1.
            To continue case sensitive comparison on the :#{attribute.name} attribute in #{klass} model,
            pass `case_sensitive: true` option explicitly to the uniqueness validator.
          MSG
          attribute.eq(Arel::Nodes::Bin.new(value))
        else
          super
        end
      end

      def case_sensitive_comparison(attribute, value) # :nodoc:
        column = column_for_attribute(attribute)

        if column.collation && !column.case_sensitive?
          attribute.eq(Arel::Nodes::Bin.new(value))
        else
          super
        end
      end

      def can_perform_case_insensitive_comparison_for?(column)
        column.case_sensitive?
      end
      private :can_perform_case_insensitive_comparison_for?

      # In MySQL 5.7.5 and up, ONLY_FULL_GROUP_BY affects handling of queries that use
      # DISTINCT and ORDER BY. It requires the ORDER BY columns in the select list for
      # distinct queries, and requires that the ORDER BY include the distinct column.
      # See https://dev.mysql.com/doc/refman/5.7/en/group-by-handling.html
      def columns_for_distinct(columns, orders) # :nodoc:
        order_columns = orders.reject(&:blank?).map { |s|
          # Convert Arel node to string
          s = s.to_sql unless s.is_a?(String)
          # Remove any ASC/DESC modifiers
          s.gsub(/\s+(?:ASC|DESC)\b/i, "")
        }.reject(&:blank?).map.with_index { |column, i| "#{column} AS alias_#{i}" }

        (order_columns << super).join(", ")
      end

      def strict_mode?
        self.class.type_cast_config_to_boolean(@config.fetch(:strict, true))
      end

      def default_index_type?(index) # :nodoc:
        index.using == :btree || super
      end

      def build_insert_sql(insert) # :nodoc:
        sql = +"INSERT #{insert.into} #{insert.values_list}"

        if insert.skip_duplicates?
          no_op_column = quote_column_name(insert.keys.first)
          sql << " ON DUPLICATE KEY UPDATE #{no_op_column}=#{no_op_column}"
        elsif insert.update_duplicates?
          sql << " ON DUPLICATE KEY UPDATE "
          sql << insert.updatable_columns.map { |column| "#{column}=VALUES(#{column})" }.join(",")
        end

        sql
      end

      def check_version # :nodoc:
        if database_version < "5.5.8"
          raise "Your version of MySQL (#{database_version}) is too old. Active Record supports MySQL >= 5.5.8."
        end
      end

      private

        def initialize_type_map(m = type_map)
          super

          register_class_with_limit m, %r(char)i, MysqlString

          m.register_type %r(tinytext)i,   Type::Text.new(limit: 2**8 - 1)
          m.register_type %r(tinyblob)i,   Type::Binary.new(limit: 2**8 - 1)
          m.register_type %r(text)i,       Type::Text.new(limit: 2**16 - 1)
          m.register_type %r(blob)i,       Type::Binary.new(limit: 2**16 - 1)
          m.register_type %r(mediumtext)i, Type::Text.new(limit: 2**24 - 1)
          m.register_type %r(mediumblob)i, Type::Binary.new(limit: 2**24 - 1)
          m.register_type %r(longtext)i,   Type::Text.new(limit: 2**32 - 1)
          m.register_type %r(longblob)i,   Type::Binary.new(limit: 2**32 - 1)
          m.register_type %r(^float)i,     Type::Float.new(limit: 24)
          m.register_type %r(^double)i,    Type::Float.new(limit: 53)

          register_integer_type m, %r(^bigint)i,    limit: 8
          register_integer_type m, %r(^int)i,       limit: 4
          register_integer_type m, %r(^mediumint)i, limit: 3
          register_integer_type m, %r(^smallint)i,  limit: 2
          register_integer_type m, %r(^tinyint)i,   limit: 1

          m.register_type %r(^tinyint\(1\))i, Type::Boolean.new if emulate_booleans
          m.alias_type %r(year)i,          "integer"
          m.alias_type %r(bit)i,           "binary"

          m.register_type(%r(enum)i) do |sql_type|
            limit = sql_type[/^enum\s*\((.+)\)/i, 1]
              .split(",").map { |enum| enum.strip.length - 2 }.max
            MysqlString.new(limit: limit)
          end

          m.register_type(%r(^set)i) do |sql_type|
            limit = sql_type[/^set\s*\((.+)\)/i, 1]
              .split(",").map { |set| set.strip.length - 1 }.sum - 1
            MysqlString.new(limit: limit)
          end
        end

        def register_integer_type(mapping, key, options)
          mapping.register_type(key) do |sql_type|
            if /\bunsigned\b/.match?(sql_type)
              Type::UnsignedInteger.new(options)
            else
              Type::Integer.new(options)
            end
          end
        end

        def extract_precision(sql_type)
          if /\A(?:date)?time(?:stamp)?\b/.match?(sql_type)
            super || 0
          else
            super
          end
        end

        # See https://dev.mysql.com/doc/refman/5.7/en/error-messages-server.html
        ER_FILSORT_ABORT        = 1028
        ER_DUP_ENTRY            = 1062
        ER_NOT_NULL_VIOLATION   = 1048
        ER_NO_REFERENCED_ROW    = 1216
        ER_ROW_IS_REFERENCED    = 1217
        ER_DO_NOT_HAVE_DEFAULT  = 1364
        ER_ROW_IS_REFERENCED_2  = 1451
        ER_NO_REFERENCED_ROW_2  = 1452
        ER_DATA_TOO_LONG        = 1406
        ER_OUT_OF_RANGE         = 1264
        ER_LOCK_DEADLOCK        = 1213
        ER_CANNOT_ADD_FOREIGN   = 1215
        ER_CANNOT_CREATE_TABLE  = 1005
        ER_LOCK_WAIT_TIMEOUT    = 1205
        ER_QUERY_INTERRUPTED    = 1317
        ER_QUERY_TIMEOUT        = 3024
        ER_FK_INCOMPATIBLE_COLUMNS = 3780

        def translate_exception(exception, message:, sql:, binds:)
          case error_number(exception)
          when ER_DUP_ENTRY
            RecordNotUnique.new(message, sql: sql, binds: binds)
          when ER_NO_REFERENCED_ROW, ER_ROW_IS_REFERENCED, ER_ROW_IS_REFERENCED_2, ER_NO_REFERENCED_ROW_2
            InvalidForeignKey.new(message, sql: sql, binds: binds)
          when ER_CANNOT_ADD_FOREIGN, ER_FK_INCOMPATIBLE_COLUMNS
            mismatched_foreign_key(message, sql: sql, binds: binds)
          when ER_CANNOT_CREATE_TABLE
            if message.include?("errno: 150")
              mismatched_foreign_key(message, sql: sql, binds: binds)
            else
              super
            end
          when ER_DATA_TOO_LONG
            ValueTooLong.new(message, sql: sql, binds: binds)
          when ER_OUT_OF_RANGE
            RangeError.new(message, sql: sql, binds: binds)
          when ER_NOT_NULL_VIOLATION, ER_DO_NOT_HAVE_DEFAULT
            NotNullViolation.new(message, sql: sql, binds: binds)
          when ER_LOCK_DEADLOCK
            Deadlocked.new(message, sql: sql, binds: binds)
          when ER_LOCK_WAIT_TIMEOUT
            LockWaitTimeout.new(message, sql: sql, binds: binds)
          when ER_QUERY_TIMEOUT, ER_FILSORT_ABORT
            StatementTimeout.new(message, sql: sql, binds: binds)
          when ER_QUERY_INTERRUPTED
            QueryCanceled.new(message, sql: sql, binds: binds)
          else
            super
          end
        end

        def change_column_for_alter(table_name, column_name, type, options = {})
          column = column_for(table_name, column_name)
          type ||= column.sql_type

          unless options.key?(:default)
            options[:default] = column.default
          end

          unless options.key?(:null)
            options[:null] = column.null
          end

          unless options.key?(:comment)
            options[:comment] = column.comment
          end

          td = create_table_definition(table_name)
          cd = td.new_column_definition(column.name, type, options)
          schema_creation.accept(ChangeColumnDefinition.new(cd, column.name))
        end

        def rename_column_for_alter(table_name, column_name, new_column_name)
          column  = column_for(table_name, column_name)
          options = {
            default: column.default,
            null: column.null,
            auto_increment: column.auto_increment?
          }

          current_type = exec_query("SHOW COLUMNS FROM #{quote_table_name(table_name)} LIKE #{quote(column_name)}", "SCHEMA").first["Type"]
          td = create_table_definition(table_name)
          cd = td.new_column_definition(new_column_name, current_type, options)
          schema_creation.accept(ChangeColumnDefinition.new(cd, column.name))
        end

        def add_index_for_alter(table_name, column_name, options = {})
          index_name, index_type, index_columns, _, index_algorithm, index_using = add_index_options(table_name, column_name, options)
          index_algorithm[0, 0] = ", " if index_algorithm.present?
          "ADD #{index_type} INDEX #{quote_column_name(index_name)} #{index_using} (#{index_columns})#{index_algorithm}"
        end

        def remove_index_for_alter(table_name, options = {})
          index_name = index_name_for_remove(table_name, options)
          "DROP INDEX #{quote_column_name(index_name)}"
        end

        def add_timestamps_for_alter(table_name, options = {})
          options[:null] = false if options[:null].nil?

          if !options.key?(:precision) && supports_datetime_with_precision?
            options[:precision] = 6
          end

          [add_column_for_alter(table_name, :created_at, :datetime, options), add_column_for_alter(table_name, :updated_at, :datetime, options)]
        end

        def remove_timestamps_for_alter(table_name, options = {})
          [remove_column_for_alter(table_name, :updated_at), remove_column_for_alter(table_name, :created_at)]
        end

        def supports_rename_index?
          mariadb? ? false : database_version >= "5.7.6"
        end

        def configure_connection
          variables = @config.fetch(:variables, {}).stringify_keys

          # By default, MySQL 'where id is null' selects the last inserted id; Turn this off.
          variables["sql_auto_is_null"] = 0

          # Increase timeout so the server doesn't disconnect us.
          wait_timeout = self.class.type_cast_config_to_integer(@config[:wait_timeout])
          wait_timeout = 2147483 unless wait_timeout.is_a?(Integer)
          variables["wait_timeout"] = wait_timeout

          defaults = [":default", :default].to_set

          # Make MySQL reject illegal values rather than truncating or blanking them, see
          # https://dev.mysql.com/doc/refman/5.7/en/sql-mode.html#sqlmode_strict_all_tables
          # If the user has provided another value for sql_mode, don't replace it.
          if sql_mode = variables.delete("sql_mode")
            sql_mode = quote(sql_mode)
          elsif !defaults.include?(strict_mode?)
            if strict_mode?
              sql_mode = "CONCAT(@@sql_mode, ',STRICT_ALL_TABLES')"
            else
              sql_mode = "REPLACE(@@sql_mode, 'STRICT_TRANS_TABLES', '')"
              sql_mode = "REPLACE(#{sql_mode}, 'STRICT_ALL_TABLES', '')"
              sql_mode = "REPLACE(#{sql_mode}, 'TRADITIONAL', '')"
            end
            sql_mode = "CONCAT(#{sql_mode}, ',NO_AUTO_VALUE_ON_ZERO')"
          end
          sql_mode_assignment = "@@SESSION.sql_mode = #{sql_mode}, " if sql_mode

          # NAMES does not have an equals sign, see
          # https://dev.mysql.com/doc/refman/5.7/en/set-names.html
          # (trailing comma because variable_assignments will always have content)
          if @config[:encoding]
            encoding = +"NAMES #{@config[:encoding]}"
            encoding << " COLLATE #{@config[:collation]}" if @config[:collation]
            encoding << ", "
          end

          # Gather up all of the SET variables...
          variable_assignments = variables.map do |k, v|
            if defaults.include?(v)
              "@@SESSION.#{k} = DEFAULT" # Sets the value to the global or compile default
            elsif !v.nil?
              "@@SESSION.#{k} = #{quote(v)}"
            end
            # or else nil; compact to clear nils out
          end.compact.join(", ")

          # ...and send them all in one query
          execute "SET #{encoding} #{sql_mode_assignment} #{variable_assignments}"
        end

        def column_definitions(table_name) # :nodoc:
          execute_and_free("SHOW FULL FIELDS FROM #{quote_table_name(table_name)}", "SCHEMA") do |result|
            each_hash(result)
          end
        end

        def create_table_info(table_name) # :nodoc:
          exec_query("SHOW CREATE TABLE #{quote_table_name(table_name)}", "SCHEMA").first["Create Table"]
        end

        def arel_visitor
          Arel::Visitors::MySQL.new(self)
        end

        def build_statement_pool
          StatementPool.new(self.class.type_cast_config_to_integer(@config[:statement_limit]))
        end

        def mismatched_foreign_key(message, sql:, binds:)
          match = %r/
            (?:CREATE|ALTER)\s+TABLE\s*(?:`?\w+`?\.)?`?(?<table>\w+)`?.+?
            FOREIGN\s+KEY\s*\(`?(?<foreign_key>\w+)`?\)\s*
            REFERENCES\s*(`?(?<target_table>\w+)`?)\s*\(`?(?<primary_key>\w+)`?\)
          /xmi.match(sql)

          options = {
            message: message,
            sql: sql,
            binds: binds,
          }

          if match
            options[:table] = match[:table]
            options[:foreign_key] = match[:foreign_key]
            options[:target_table] = match[:target_table]
            options[:primary_key] = match[:primary_key]
            options[:primary_key_column] = column_for(match[:target_table], match[:primary_key])
          end

          MismatchedForeignKey.new(options)
        end

        def version_string(full_version_string)
          full_version_string.match(/^(?:5\.5\.5-)?(\d+\.\d+\.\d+)/)[1]
        end

        class MysqlString < Type::String # :nodoc:
          def serialize(value)
            case value
            when true then "1"
            when false then "0"
            else super
            end
          end

          private

            def cast_value(value)
              case value
              when true then "1"
              when false then "0"
              else super
              end
            end
        end

        ActiveRecord::Type.register(:string, MysqlString, adapter: :mysql2)
        ActiveRecord::Type.register(:unsigned_integer, Type::UnsignedInteger, adapter: :mysql2)
    end
  end
end
