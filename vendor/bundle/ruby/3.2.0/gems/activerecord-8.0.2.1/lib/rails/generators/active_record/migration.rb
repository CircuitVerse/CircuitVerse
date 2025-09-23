# frozen_string_literal: true

require "rails/generators/migration"

module ActiveRecord
  module Generators # :nodoc:
    module Migration
      extend ActiveSupport::Concern
      include Rails::Generators::Migration

      module ClassMethods
        # Implement the required interface for Rails::Generators::Migration.
        def next_migration_number(dirname)
          next_migration_number = current_migration_number(dirname) + 1
          ActiveRecord::Migration.next_migration_number(next_migration_number)
        end
      end

      private
        def primary_key_type
          key_type = options[:primary_key_type]
          ", id: :#{key_type}" if key_type
        end

        def foreign_key_type
          key_type = options[:primary_key_type]
          ", type: :#{key_type}" if key_type
        end

        def db_migrate_path
          if defined?(Rails.application) && Rails.application
            configured_migrate_path || default_migrate_path
          else
            "db/migrate"
          end
        end

        def default_migrate_path
          Rails.application.config.paths["db/migrate"].to_ary.first
        end

        def configured_migrate_path
          return unless database = options[:database]

          config = ActiveRecord::Base.configurations.configs_for(
            env_name: Rails.env,
            name: database
          )

          Array(config&.migrations_paths).first
        end
    end
  end
end
