require 'capybara/rspec'
require 'selenium/webdriver'
require 'tmpdir'

Capybara.register_driver :headless_chrome do |app|
  chrome_opts = ::Selenium::WebDriver::Chrome::Options.new

  chrome_opts.add_argument('--headless')
  chrome_opts.add_argument('--disable-gpu')
  chrome_opts.add_argument('--no-sandbox')
  chrome_opts.add_argument('--disable-dev-shm-usage')
  chrome_opts.add_argument('--window-size=1400,1400')

  profile_dir = File.join(Dir.tmpdir, "chrome-profile-#{Process.pid}")
  chrome_opts.add_argument("--user-data-dir=#{profile_dir}")

  Capybara::Selenium::Driver.new(app,
    browser: :chrome,
    capabilities: chrome_opts
  )
end

Capybara.javascript_driver = :headless_chrome
