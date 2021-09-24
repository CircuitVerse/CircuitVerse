require 'rails/generators/named_base'

# This class generates a migration file for deleting and creating
# a DynamoDB sessions table.
module DynamoDb
  module Generators
    # Generates an ActiveRecord migration that creates and deletes a DynamoDB
    # Session table.
    class SessionStoreMigrationGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      # Desired name of migration class
      argument :name, type: :string, default: 'create_dynamo_db_sessions_table'

      # @return [Rails Migration File] migration file for creation and deletion
      #   of a DynamoDB session table.
      def generate_migration_file
        migration_template(
          'session_store_migration.rb',
          "db/migrate/#{name.underscore}.rb"
        )
      end

      def copy_sample_config_file
        template(
          'dynamo_db_session_store.yml',
          'config/dynamo_db_session_store.yml'
        )
      end

      # Next migration number - must be implemented
      def self.next_migration_number(_dir = nil)
        Time.now.utc.strftime('%Y%m%d%H%M%S')
      end

      private

      # @return [String] activerecord migration version
      def migration_version
        "#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"
      end
    end
  end
end
