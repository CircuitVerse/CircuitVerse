module RailsDataMigrations
  class Migrator < ::ActiveRecord::Migrator
    MIGRATOR_SALT = 2053462855

    def record_version_state_after_migrating(version)
      if down?
        migrated.delete(version)
        LogEntry.where(version: version.to_s).delete_all
      else
        migrated << version
        LogEntry.create!(version: version.to_s)
      end
    end

    class << self
      def migrations_table_exists?(connection = ActiveRecord::Base.connection)
        table_check_method = connection.respond_to?(:data_source_exists?) ? :data_source_exists? : :table_exists?
        connection.send(table_check_method, schema_migrations_table_name)
      end

      def get_all_versions(connection = ActiveRecord::Base.connection)
        if migrations_table_exists?(connection)
          LogEntry.all.map { |x| x.version.to_i }.sort
        else
          []
        end
      end

      def current_version
        get_all_versions.max || 0
      end

      def schema_migrations_table_name
        LogEntry.table_name
      end

      def migrations_path
        'db/data_migrations'
      end

      def rails_6_0?
        Rails::VERSION::MAJOR >= 6
      end

      def rails_5_2?
        Rails::VERSION::MAJOR > 5 || (Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR >= 2)
      end

      def list_migrations
        if rails_6_0?
          ::ActiveRecord::MigrationContext.new(migrations_path, ::ActiveRecord::SchemaMigration).migrations
        elsif rails_5_2?
          ::ActiveRecord::MigrationContext.new(migrations_path).migrations
        else
          migrations(migrations_path)
        end
      end

      def list_pending_migrations
        if rails_5_2?
          already_migrated = get_all_versions
          list_migrations.reject { |m| already_migrated.include?(m.version) }
        else
          open(migrations_path).pending_migrations
        end
      end

      def run_migration(direction, migrations_path, version)
        if rails_6_0?
          new(direction, list_migrations, ::ActiveRecord::SchemaMigration, version).run
        elsif rails_5_2?
          new(direction, list_migrations, version).run
        else
          run(direction, migrations_path, version)
        end
      end
    end
  end
end
