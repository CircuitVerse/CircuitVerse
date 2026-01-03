# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Autofix
      class InconsistentTypes < MigrationBase # :nodoc:
        def attributes
          {
            table_to_change: report.table_to_change,
            type_to_set: report.type_to_set,
            fk_name: report.fk_name
          }
        end

        private

        def migration_name
          "change_#{report.table_to_change}_#{report.fk_name}_to_#{report.type_to_set}"
        end

        def template_path
          File.join(__dir__, 'templates', 'inconsistent_types.tt')
        end
      end
    end
  end
end
