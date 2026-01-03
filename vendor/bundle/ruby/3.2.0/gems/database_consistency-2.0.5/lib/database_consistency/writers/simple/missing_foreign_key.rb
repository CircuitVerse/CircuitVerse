# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class MissingForeignKey < Base # :nodoc:
        private

        def template
          'should have foreign key in the database'
        end

        def unique_attributes
          {
            foreign_table: report.foreign_table,
            foreign_key: report.foreign_key,
            primary_table: report.primary_table,
            primary_key: report.primary_key
          }
        end
      end
    end
  end
end
