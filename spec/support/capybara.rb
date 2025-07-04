# frozen_string_literal: true

require "capybara/rails"
require "selenium/webdriver"
require "tmpdir"
require "securerandom"

Capybara.register_driver :headless_chrome_unique_profile do |app|
  chrome_args = %w[
    headless
    disable-gpu
    no-sandbox
    disable-dev-shm-usage
    window-size=1400,1400
  ]

  temp_profile = File.join(Dir.tmpdir, "chrome-profile-#{SecureRandom.uuid}")
  Dir.mkdir(temp_profile)
  chrome_args << "user-data-dir=#{temp_profile}"

  options = Selenium::WebDriver::Chrome::Options.new(args: chrome_args)
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

RSpec.configure do |config|
  config.before(type: :system) do
    driven_by :rack_test
  end

  config.before(type: :system, js: true) do
    driven_by :headless_chrome_unique_profile
  end
end

Capybara.javascript_driver = :headless_chrome_unique_profile
