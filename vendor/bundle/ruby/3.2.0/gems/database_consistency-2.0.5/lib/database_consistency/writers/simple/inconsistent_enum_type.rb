# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class InconsistentEnumType < Base # :nodoc:
        private

        def template
          'enum has %<values_types>s types but column has %<column_type>s type'
        end

        def attributes
          {
            values_types: report.values_types.join(', '),
            column_type: report.column_type
          }
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
