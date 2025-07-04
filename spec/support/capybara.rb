# frozen_string_literal: true

require "capybara/rails"
require "capybara/playwright/driver"

Capybara.register_driver :playwright do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :chromium)
end

RSpec.configure do |config|
  config.before(type: :system) do
    driven_by :rack_test
  end

  config.before(type: :system, js: true) do
    driven_by :playwright
  end
end

Capybara.javascript_driver = :playwright
Capybara.default_driver = :playwright
Capybara.default_max_wait_time = 15
Capybara.raise_server_errors = false
