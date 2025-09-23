# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class ImplicitOrderColumnMissing < Base # :nodoc:
        private

        def template
          'implicit_order_column is recommended when using uuid column type for primary key'
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
