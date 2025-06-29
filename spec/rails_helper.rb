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

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
Capybara.default_max_wait_time = 3

RSpec.configure do |config|
  config.fixture_path = Rails.root.join("spec/fixtures")
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    Flipper.enable(:active_storage_s3)
    Flipper.enable(:contests)
  end

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include ActionDispatch::TestProcess
  config.include Warden::Test::Helpers
  config.include ViewComponent::TestHelpers, type: :component
  config.include Devise::Test::ControllerHelpers, type: :controller

  config.before(type: :system) do
    driven_by :rack_test
  end

  config.before(type: :system, js: true) do
    driven_by :headless_chrome_unique_profile
  end

  config.define_derived_metadata(
    file_path: %r{spec/system/(group_spec|project_spec|user_profile_spec)\.rb}
  ) do |metadata|
    metadata[:js] = true
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
