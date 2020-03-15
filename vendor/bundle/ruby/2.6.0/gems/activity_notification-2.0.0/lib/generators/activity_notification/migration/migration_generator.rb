require 'rails/generators/active_record'

module ActivityNotification
  module Generators
    # Migration generator to create migration files from templates.
    # @example Run migration generator
    #   rails generate activity_notification:migration
    class MigrationGenerator < ActiveRecord::Generators::Base
      MIGRATION_TABLES = ['notifications', 'subscriptions'].freeze

      source_root File.expand_path("../../../templates/migrations", __FILE__)

      argument :name, type: :string, default: 'CreateActivityNotificationTables',
        desc: "The migration name to create tables"
      class_option :tables, aliases: "-t", type: :array,
        desc: "Select specific tables to generate (#{MIGRATION_TABLES.join(', ')})"

      # Create migration files in application directory
      def create_migrations
        @migration_name = name
        @migration_tables = options[:tables] || MIGRATION_TABLES
        migration_template 'migration.rb', "db/migrate/#{name.underscore}.rb"
      end
    end
  end
end
