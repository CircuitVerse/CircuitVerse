# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class MissingAssociationClass < Base # :nodoc:
        private

        def template
          'refers to undefined model %<class_name>s'
        end

        def unique_attributes
          {
            class_name: report.class_name
          }
        end

        def attributes
          {
            class_name: report.class_name
          }
        end
      end
    end
  end
end
