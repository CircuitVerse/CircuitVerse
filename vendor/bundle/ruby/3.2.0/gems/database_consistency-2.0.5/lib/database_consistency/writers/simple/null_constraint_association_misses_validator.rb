# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class NullConstraintAssociationMissesValidator < Base # :nodoc:
        private

        def template
          'column is required in the database but do not have presence validator for association %<association_name>s'
        end

        def attributes
          {
            association_name: report.association_name
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
