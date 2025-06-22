# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "devise"

# Include support files
Rails.root.glob("spec/support/**/*.rb").each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

# Capybara wait time
Capybara.default_max_wait_time = 3

# === Playwright driver for system specs ===
require "capybara/playwright/driver"

Capybara.register_driver :playwright do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :chromium)
end

# RSpec config
RSpec.configure do |config|
  config.fixture_path = Rails.root.join("spec/fixtures")

  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include FactoryBot::Syntax::Methods
  config.include ActionDispatch::TestProcess
  config.include Warden::Test::Helpers
  config.include ViewComponent::TestHelpers, type: :component

  # Enable necessary feature flags
  config.before do
    Flipper.enable(:active_storage_s3)
  end

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # Use Playwright only for system specs
  config.before(type: :system) do
    driven_by :playwright
  end
end

# Shoulda Matchers setup
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
