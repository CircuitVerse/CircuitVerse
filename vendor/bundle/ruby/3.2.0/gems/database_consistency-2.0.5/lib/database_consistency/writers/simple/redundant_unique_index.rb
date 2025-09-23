# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class RedundantUniqueIndex < Base # :nodoc:
        private

        def template
          'index uniqueness is redundant as %<covered_index_name>s covers it'
        end

        def attributes
          {
            covered_index_name: report.covered_index_name
          }
        end

        def unique_attributes
          {
            index_name: report.index_name
          }
        end
      end
    end
  end
end
