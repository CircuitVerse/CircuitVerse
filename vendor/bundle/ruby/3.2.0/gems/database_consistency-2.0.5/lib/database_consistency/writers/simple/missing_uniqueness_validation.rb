# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class MissingUniquenessValidation < Base # :nodoc:
        private

        def template
          'index is unique in the database but do not have uniqueness validator'
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
