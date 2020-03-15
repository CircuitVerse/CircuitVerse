# Configure Rails Envinronment
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../dummy_app/config/environment', __FILE__)

require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'database_cleaner'

Capybara.javascript_driver = :poltergeist
Capybara.server = :webrick
Capybara.default_max_wait_time = 5

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path('../support/**/*.rb', __FILE__)].each {|f| require f }

RSpec.configure do |config|
  load "#{Rails.root.to_s}/db/schema.rb" # use db agnostic schema by default

  config.mock_with :rspec
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.fixture_path = File.expand_path('../fixtures', __FILE__)

  config.include Rails.application.routes.url_helpers
  config.include RSpec::Matchers
  config.include Capybara::DSL, type: :feature
  config.include IntegrationHelper, type: :feature

  config.before do |example|
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
