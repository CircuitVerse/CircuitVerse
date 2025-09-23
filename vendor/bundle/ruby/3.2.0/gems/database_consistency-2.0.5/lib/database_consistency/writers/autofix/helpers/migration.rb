# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Autofix
      module Helpers
        module Migration # :nodoc:
          def migration_path(name)
            last = migration_context.migrations.last
            version = ActiveRecord::Migration.next_migration_number(last&.version.to_i + 1)

            "db/migrate/#{version}_#{name.underscore}.rb"
          end

          def migration_path_pattern(name)
            "db/migrate/*_#{name.underscore}.rb"
          end

          def migration_configuration(name)
            {
              migration_name: name.camelcase,
              migration_version: ActiveRecord::Migration.current_version
            }
          end

          def migration_context
            if ActiveRecord::MigrationContext.instance_method(:initialize).arity == 1
              return ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths)
            end

            if ActiveRecord::Base.connection.respond_to?(:schema_migration)
              return ActiveRecord::MigrationContext.new(
                ActiveRecord::Migrator.migrations_paths,
                ActiveRecord::Base.connection.schema_migration
              )
            end

            ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths)
          end
        end
      end
    end
  end
end
