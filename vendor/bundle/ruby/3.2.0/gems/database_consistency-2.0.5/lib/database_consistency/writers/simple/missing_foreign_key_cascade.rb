# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Simple
      class MissingForeignKeyCascade < Base # :nodoc:
        private

        def template
          'should have foreign key with on_delete: :%<cascade_option>s in the database'
        end

        def attributes
          {
            cascade_option: report.cascade_option
          }
        end

        def unique_attributes
          {
            foreign_table: report.foreign_table,
            foreign_key: report.foreign_key,
            primary_table: report.primary_table,
            primary_key: report.primary_key,
            cascade_option: report.cascade_option
          }
        end
      end
    end
  end
end
