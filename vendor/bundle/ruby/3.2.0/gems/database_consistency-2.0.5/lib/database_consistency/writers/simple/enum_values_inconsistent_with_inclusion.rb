# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class EnumValuesInconsistentWithInclusion < Base # :nodoc:
        private

        def template
          'enum has [%<enum_values>s] values but ActiveRecord inclusion validation has [%<declared_values>s] values'
        end

        def attributes
          {
            enum_values: report.enum_values.join(', '),
            declared_values: report.declared_values.join(', ')
          }
        end

        def unique_attributes
          {
            table_or_model_name: report.table_or_model_name,
            column_or_attribute_name: report.column_or_attribute_name,
            inclusion: true
          }
        end
      end
    end
  end
end
