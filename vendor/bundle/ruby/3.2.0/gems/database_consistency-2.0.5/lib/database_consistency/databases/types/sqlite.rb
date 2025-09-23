# frozen_string_literal: true

module DatabaseConsistency
  module Databases
    module Types
      # Wraps types for SQLite database
      class Sqlite < Base
        TYPES = {
          'bigserial' => 'bigint',
          'serial' => 'integer',
          'integer(8)' => 'bigint',
          'integer(4)' => 'integer',
          'integer(2)' => 'smallint'
        }.freeze

        # @return [String]
        def convert
          TYPES[type] || type
        end
      end
    end
  end
end
