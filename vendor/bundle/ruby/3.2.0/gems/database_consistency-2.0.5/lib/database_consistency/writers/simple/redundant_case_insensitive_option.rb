# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class RedundantCaseInsensitiveOption < Base # :nodoc:
        private

        def template
          "has case insensitive type and doesn't require case_sensitive: false option"
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
