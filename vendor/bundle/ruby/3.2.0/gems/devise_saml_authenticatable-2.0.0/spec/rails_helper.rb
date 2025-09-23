ENV["RAILS_ENV"] ||= 'test'

require 'spec_helper'

create_app('sp', 'USE_SUBJECT_TO_AUTHENTICATE' => "false")
require "#{working_directory}/sp/config/environment"
require 'rspec/rails'

# Starting from Rails 8.0, routes are lazy-loaded by default in test and development environments.
# However, Devise's mappings are built during the routes loading phase.
# To ensure it works correctly, we need to load the routes first before accessing @@mappings.
if defined?(Rails) && Gem::Version.new(Rails.version) > Gem::Version.new('7.2')
  require 'devise'
  module Devise
    def self.mappings
      Rails.application.try(:reload_routes_unless_loaded)
      @@mappings
    end
  end
end

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
if ActiveRecord::Base.connection.respond_to?(:migration_context)
  ActiveRecord::Base.connection.migration_context.migrate
else
  ActiveRecord::MigrationContext.new("#{working_directory}/sp/db/migrate/").migrate
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end

Devise.setup do |config|
  config.saml_default_user_key = :email
  config.saml_session_index_key = :session_index
end
