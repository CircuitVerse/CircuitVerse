# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class NullConstraintMissing < Base # :nodoc:
        private

        def template
          'column should be required in the database'
        end

        def unique_attributes
          {
            table_name: report.table_name,
            column_name: report.column_name
          }
        end
      end
    end
  end
end
