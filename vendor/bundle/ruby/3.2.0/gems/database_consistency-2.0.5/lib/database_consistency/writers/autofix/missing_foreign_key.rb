# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Autofix
      class MissingForeignKey < MigrationBase # :nodoc:
        def attributes
          {
            foreign_table: report.foreign_table,
            foreign_key: report.foreign_key,
            primary_table: report.primary_table,
            primary_key: report.primary_key
          }
        end

        private

        def migration_name
          "add_#{report.primary_table}_#{report.primary_key}_#{report.foreign_table}_#{report.foreign_key}_fk"
        end

        def template_path
          File.join(__dir__, 'templates', 'missing_foreign_key.tt')
        end
      end
    end
  end
end
