# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class SmallPrimaryKey < Base # :nodoc:
        private

        def template
          'column has int/serial type but recommended to have bigint/bigserial/uuid'
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
