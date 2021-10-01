# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/datastores/mongo/obfuscator'

module NewRelic
  module Agent
    module Datastores
      module Mongo
        module StatementFormatter

          PLAINTEXT_KEYS = [
            :database,
            :collection,
            :operation,
            :fields,
            :skip,
            :limit,
            :order
          ]

          OBFUSCATE_KEYS = [
            :selector
          ]

          def self.format(statement, operation)
            return nil unless NewRelic::Agent.config[:'mongo.capture_queries']

            result = { :operation => operation }

            PLAINTEXT_KEYS.each do |key|
              result[key] = statement[key] if statement.key?(key)
            end

            OBFUSCATE_KEYS.each do |key|
              if statement.key?(key) && statement[key]
                obfuscated = obfuscate(statement[key])
                result[key] = obfuscated if obfuscated
              end
            end
            result
          end

          def self.obfuscate(statement)
            statement = Obfuscator.obfuscate_statement(statement) if NewRelic::Agent.config[:'mongo.obfuscate_queries']
            statement
          end
        end
      end
    end
  end
end
