# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "devise"
# Including support files for tests
Rails.root.glob("spec/support/**/*.rb").each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  # Your code that might raise an exception
rescue StandardError => e
  puts e.to_s.strip
  exit 1
end

Capybara.raise_server_errors = false
Capybara.default_driver = :playwright
Capybara.javascript_driver = :playwright

Capybara.default_max_wait_time = 15

# === USE PLAYWRIGHT FOR SYSTEM TESTS ===
require "capybara/playwright/driver"

Capybara.register_driver :playwright do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :chromium)
end

RSpec.configure do |config|
  config.fixture_path = Rails.root.join("spec/fixtures")

  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include FactoryBot::Syntax::Methods
  config.include ActionDispatch::TestProcess
  config.include Warden::Test::Helpers
  config.include ViewComponent::TestHelpers, type: :component
  config.include Devise::Test::ControllerHelpers, type: :controller

  config.before do
    Flipper.enable(:active_storage_s3)
  end

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  Shoulda::Matchers.configure do |shoulda_config|
    shoulda_config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  # Use Playwright for system specs
  config.before(type: :system) do
    driven_by :playwright
  end
end
