# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class ThreeStateBoolean < Base # :nodoc:
        private

        def template
          'boolean column should have NOT NULL constraint'
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
