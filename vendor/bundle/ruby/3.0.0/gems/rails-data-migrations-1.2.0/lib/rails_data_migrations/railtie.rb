require 'rails'

module RailsDataMigrations
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load File.join(File.dirname(__FILE__), '..', 'tasks/data_migrations.rake')
    end
  end
end