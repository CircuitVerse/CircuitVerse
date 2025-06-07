# frozen_string_literal: true

require "capybara/rspec"
require "selenium/webdriver"
require "tmpdir"

Capybara.register_driver :selenium_chrome_headless do |app|
  chrome_opts = Selenium::WebDriver::Chrome::Options.new

  chrome_opts.add_argument("--headless")
  chrome_opts.add_argument("--disable-gpu")
  chrome_opts.add_argument("--no-sandbox")
  chrome_opts.add_argument("--disable-dev-shm-usage")
  chrome_opts.add_argument("--window-size=1400,1400")

  profile_dir = Dir.mktmpdir("chrome-profile-")
  chrome_opts.add_argument("--user-data-dir=#{profile_dir}")

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: chrome_opts
  )
end

Capybara.register_driver :headless_chrome, &Capybara.drivers[:selenium_chrome_headless]

RSpec.configure do |config|
  config.before(type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end

  config.before(type: :system, js: false) do
    driven_by :rack_test
  end
end
