# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class MissingTable < Base # :nodoc:
        private

        def template
          'should have a table in the database'
        end

        def unique_attributes
          {
            table_or_model_name: report.table_or_model_name
          }
        end
      end
    end
  end
end
