# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class MissingUniqueIndex < Base # :nodoc:
        private

        def template
          'model should have proper unique index in the database'
        end

        def unique_attributes
          {
            table_name: report.table_name,
            columns: report.columns,
            unique: true
          }
        end
      end
    end
  end
end
