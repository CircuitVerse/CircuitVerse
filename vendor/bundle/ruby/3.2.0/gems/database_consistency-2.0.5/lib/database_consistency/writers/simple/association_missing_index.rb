# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class AssociationMissingIndex < Base # :nodoc:
        private

        def template
          'associated model should have proper index in the database'
        end

        def unique_attributes
          {
            table_name: report.table_name,
            columns: report.columns
          }
        end
      end
    end
  end
end
