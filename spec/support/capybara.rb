# frozen_string_literal: true

require "capybara/rails"
require "tmpdir"
require "securerandom"


RSpec.configure do |config|
  config.before(type: :system) do
    driven_by :playwright
  end
end

Capybara.register_driver :playwright do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :chromium)
end

Capybara.javascript_driver = :playwright
