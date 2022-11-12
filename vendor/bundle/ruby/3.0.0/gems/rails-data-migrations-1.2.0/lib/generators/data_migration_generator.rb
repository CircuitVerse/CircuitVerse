require 'rails/generators'
require 'rails-data-migrations'

class DataMigrationGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def create_migration_file
    migration_file_name =
      "#{RailsDataMigrations::Migrator.migrations_path}/#{Time.now.utc.strftime('%Y%m%d%H%M%S')}_#{file_name}.rb"
    copy_file 'data_migration_generator.rb', migration_file_name do |content|
      content.sub(/ClassName/, file_name.camelize)
    end
  end
end
