# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'opentelemetry-helpers-sql-obfuscation'
require_relative '../constants'
require_relative '../lru_cache'

module OpenTelemetry
  module Instrumentation
    module PG
      module Patches
        # Module to prepend to PG::Connection for instrumentation
        module Connection # rubocop:disable Metrics/ModuleLength
          # Capture the first word (including letters, digits, underscores, & '.', ) that follows common table commands
          TABLE_NAME = /\b(?:FROM|INTO|UPDATE|CREATE\s+TABLE(?:\s+IF\s+NOT\s+EXISTS)?|DROP\s+TABLE(?:\s+IF\s+EXISTS)?|ALTER\s+TABLE(?:\s+IF\s+EXISTS)?)\s+["]?([\w\.]+)["]?/i

          PG::Constants::EXEC_ISH_METHODS.each do |method|
            define_method method do |*args, &block|
              span_name, attrs = span_attrs(:query, *args)
              tracer.in_span(span_name, attributes: attrs, kind: :client) do
                if block
                  block.call(super(*args))
                else
                  super(*args)
                end
              end
            end
          end

          PG::Constants::PREPARE_ISH_METHODS.each do |method|
            define_method method do |*args|
              span_name, attrs = span_attrs(:prepare, *args)
              tracer.in_span(span_name, attributes: attrs, kind: :client) do
                super(*args)
              end
            end
          end

          PG::Constants::EXEC_PREPARED_ISH_METHODS.each do |method|
            define_method method do |*args, &block|
              span_name, attrs = span_attrs(:execute, *args)
              tracer.in_span(span_name, attributes: attrs, kind: :client) do
                if block
                  block.call(super(*args))
                else
                  super(*args)
                end
              end
            end
          end

          private

          def obfuscate_sql(sql)
            return sql unless config[:db_statement] == :obfuscate

            OpenTelemetry::Helpers::SqlObfuscation.obfuscate_sql(
              sql,
              obfuscation_limit: config[:obfuscation_limit],
              adapter: :postgres
            )
          end

          def tracer
            PG::Instrumentation.instance.tracer
          end

          def config
            PG::Instrumentation.instance.config
          end

          def lru_cache
            # When SQL is being sanitized, we know that this cache will
            # never be more than 50 entries * 2000 characters (so, presumably
            # 100k bytes - or 97k). When not sanitizing SQL, then this cache
            # could grow much larger - but the small cache size should otherwise
            # help contain memory growth. The intended use here is to cache
            # prepared SQL statements, so that we can attach a reasonable
            # `db.sql.statement` value to spans when those prepared statements
            # are executed later on.
            @lru_cache ||= LruCache.new(50)
          end

          # Rubocop is complaining about 19.31/18 for Metrics/AbcSize.
          # But, getting that metric in line would force us over the
          # module size limit! We can't win here unless we want to start
          # abstracting things into a million pieces.
          def span_attrs(kind, *args)
            text = args[0]

            if kind == :query
              operation = extract_operation(text)
              sql = obfuscate_sql(text).to_s
            else
              statement_name = text

              if kind == :prepare
                sql = obfuscate_sql(args[1]).to_s
                lru_cache[statement_name] = sql
                operation = 'PREPARE'
              else
                sql = lru_cache[statement_name]
                operation = 'EXECUTE'
              end
            end

            attrs = { 'db.operation' => validated_operation(operation), 'db.postgresql.prepared_statement_name' => statement_name }
            attrs['db.statement'] = sql unless config[:db_statement] == :omit
            attrs['db.collection.name'] = collection_name(text)
            attrs.merge!(OpenTelemetry::Instrumentation::PG.attributes)
            attrs.compact!

            [span_name(operation), client_attributes.merge(attrs)]
          end

          def extract_operation(sql)
            # From: https://github.com/open-telemetry/opentelemetry-js-contrib/blob/9244a08a8d014afe26b82b91cf86e407c2599d73/plugins/node/opentelemetry-instrumentation-pg/src/utils.ts#L35
            # Ignores prepend comment
            comment_regex = %r{\A\/\*.*?\*\/}m
            sql.to_s.sub(comment_regex, '').split[0].to_s.upcase
          end

          def span_name(operation)
            [validated_operation(operation), db].compact.join(' ')
          end

          def validated_operation(operation)
            operation if PG::Constants::SQL_COMMANDS.include?(operation)
          end

          def collection_name(text)
            text.scan(TABLE_NAME).flatten[0]
          rescue StandardError
            nil
          end

          def client_attributes
            attributes = {
              'db.system' => 'postgresql',
              'db.user' => user,
              'db.name' => db
            }
            attributes['peer.service'] = config[:peer_service] if config[:peer_service]

            attributes.merge!(transport_attrs)
            attributes.compact!
            attributes
          end

          def transport_addr
            # The hostaddr method is available when the gem is built against
            # a recent version of libpq.
            return hostaddr if defined?(hostaddr)

            # As a fallback, we can use the hostaddr of the parsed connection
            # string when there is only one. Some older versions of libpq allow
            # multiple without any way to discern which is presently connected.
            addr = conninfo_hash[:hostaddr]
            addr unless addr&.include?(',')
          end

          def transport_attrs
            h = host
            if h&.start_with?('/')
              {
                'net.sock.family' => 'unix',
                'net.peer.name' => h
              }
            else
              {
                'net.transport' => 'ip_tcp',
                'net.peer.name' => h,
                'net.peer.ip' => transport_addr,
                'net.peer.port' => transport_port
              }
            end
          end

          def transport_port
            # The port method can fail in older versions of the gem. It is
            # accurate and safe to use when the DEF_PGPORT constant is defined.
            return port if defined?(::PG::DEF_PGPORT)

            # As a fallback, we can use the port of the parsed connection
            # string when there is exactly one.
            p = conninfo_hash[:port]
            p.to_i unless p.nil? || p.empty? || p.include?(',')
          end
        end
      end
    end
  end
end
