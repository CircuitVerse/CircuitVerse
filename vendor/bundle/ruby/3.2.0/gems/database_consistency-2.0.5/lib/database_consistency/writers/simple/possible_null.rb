# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class PossibleNull < Base # :nodoc:
        private

        def template
          'column is required but there is possible null value insert'
        end

        def unique_attributes
          {
            table_or_model_name: report.table_or_model_name,
            column_or_attribute_name: report.column_or_attribute_name
          }
        end
      end
    end
  end
end
