# frozen_string_literal: true

module ActiveRecord
  module ConnectionAdapters
    module MySQL
      module DatabaseStatements
        # Returns an ActiveRecord::Result instance.
        def select_all(*, **) # :nodoc:
          result = if ExplainRegistry.collect? && prepared_statements
            unprepared_statement { super }
          else
            super
          end
          @connection.abandon_results!
          result
        end

        def query(sql, name = nil) # :nodoc:
          execute(sql, name).to_a
        end

        READ_QUERY = ActiveRecord::ConnectionAdapters::AbstractAdapter.build_read_query_regexp(
          :desc, :describe, :set, :show, :use
        ) # :nodoc:
        private_constant :READ_QUERY

        def write_query?(sql) # :nodoc:
          !READ_QUERY.match?(sql)
        rescue ArgumentError # Invalid encoding
          !READ_QUERY.match?(sql.b)
        end

        def explain(arel, binds = [])
          sql     = "EXPLAIN #{to_sql(arel, binds)}"
          start   = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          result  = exec_query(sql, "EXPLAIN", binds)
          elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

          MySQL::ExplainPrettyPrinter.new.pp(result, elapsed)
        end

        # Executes the SQL statement in the context of this connection.
        def execute(sql, name = nil, async: false)
          sql = transform_query(sql)
          check_if_write_query(sql)

          raw_execute(sql, name, async: async)
        end

        def exec_query(sql, name = "SQL", binds = [], prepare: false, async: false) # :nodoc:
          if without_prepared_statement?(binds)
            execute_and_free(sql, name, async: async) do |result|
              if result
                build_result(columns: result.fields, rows: result.to_a)
              else
                build_result(columns: [], rows: [])
              end
            end
          else
            exec_stmt_and_free(sql, name, binds, cache_stmt: prepare, async: async) do |_, result|
              if result
                build_result(columns: result.fields, rows: result.to_a)
              else
                build_result(columns: [], rows: [])
              end
            end
          end
        end

        def exec_delete(sql, name = nil, binds = []) # :nodoc:
          if without_prepared_statement?(binds)
            @lock.synchronize do
              execute_and_free(sql, name) { @connection.affected_rows }
            end
          else
            exec_stmt_and_free(sql, name, binds) { |stmt| stmt.affected_rows }
          end
        end
        alias :exec_update :exec_delete

        # https://dev.mysql.com/doc/refman/5.7/en/date-and-time-functions.html#function_current-timestamp
        # https://dev.mysql.com/doc/refman/5.7/en/date-and-time-type-syntax.html
        HIGH_PRECISION_CURRENT_TIMESTAMP = Arel.sql("CURRENT_TIMESTAMP(6)").freeze # :nodoc:
        private_constant :HIGH_PRECISION_CURRENT_TIMESTAMP

        def high_precision_current_timestamp
          HIGH_PRECISION_CURRENT_TIMESTAMP
        end

        private
          def raw_execute(sql, name, async: false)
            # make sure we carry over any changes to ActiveRecord.default_timezone that have been
            # made since we established the connection
            @connection.query_options[:database_timezone] = ActiveRecord.default_timezone

            super
          end

          def execute_batch(statements, name = nil)
            statements = statements.map { |sql| transform_query(sql) }
            combine_multi_statements(statements).each do |statement|
              raw_execute(statement, name)
              @connection.abandon_results!
            end
          end

          def default_insert_value(column)
            super unless column.auto_increment?
          end

          def last_inserted_id(result)
            @connection.last_id
          end

          def multi_statements_enabled?
            flags = @config[:flags]

            if flags.is_a?(Array)
              flags.include?("MULTI_STATEMENTS")
            else
              flags.anybits?(Mysql2::Client::MULTI_STATEMENTS)
            end
          end

          def with_multi_statements
            multi_statements_was = multi_statements_enabled?

            unless multi_statements_was
              @connection.set_server_option(Mysql2::Client::OPTION_MULTI_STATEMENTS_ON)
            end

            yield
          ensure
            unless multi_statements_was
              @connection.set_server_option(Mysql2::Client::OPTION_MULTI_STATEMENTS_OFF)
            end
          end

          def combine_multi_statements(total_sql)
            total_sql.each_with_object([]) do |sql, total_sql_chunks|
              previous_packet = total_sql_chunks.last
              if max_allowed_packet_reached?(sql, previous_packet)
                total_sql_chunks << +sql
              else
                previous_packet << ";\n"
                previous_packet << sql
              end
            end
          end

          def max_allowed_packet_reached?(current_packet, previous_packet)
            if current_packet.bytesize > max_allowed_packet
              raise ActiveRecordError,
                "Fixtures set is too large #{current_packet.bytesize}. Consider increasing the max_allowed_packet variable."
            elsif previous_packet.nil?
              true
            else
              (current_packet.bytesize + previous_packet.bytesize + 2) > max_allowed_packet
            end
          end

          def max_allowed_packet
            @max_allowed_packet ||= show_variable("max_allowed_packet")
          end

          def exec_stmt_and_free(sql, name, binds, cache_stmt: false, async: false)
            sql = transform_query(sql)
            check_if_write_query(sql)

            materialize_transactions
            mark_transaction_written_if_write(sql)

            # make sure we carry over any changes to ActiveRecord.default_timezone that have been
            # made since we established the connection
            @connection.query_options[:database_timezone] = ActiveRecord.default_timezone

            type_casted_binds = type_casted_binds(binds)

            log(sql, name, binds, type_casted_binds, async: async) do
              if cache_stmt
                stmt = @statements[sql] ||= @connection.prepare(sql)
              else
                stmt = @connection.prepare(sql)
              end

              begin
                result = ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
                  stmt.execute(*type_casted_binds)
                end
              rescue Mysql2::Error => e
                if cache_stmt
                  @statements.delete(sql)
                else
                  stmt.close
                end
                raise e
              end

              ret = yield stmt, result
              result.free if result
              stmt.close unless cache_stmt
              ret
            end
          end
      end
    end
  end
end
