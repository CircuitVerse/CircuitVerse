# frozen_string_literal: true

require 'spec_helper'
require 'selenium-webdriver'
require 'shared_selenium_session'
require 'shared_selenium_node'
require 'rspec/shared_spec_matchers'

def selenium_host
  ENV.fetch('SELENIUM_HOST', '0.0.0.0')
end

def selenium_port
  ENV.fetch('SELENIUM_PORT', 4444)
end

def ensure_selenium_running!
  timer = Capybara::Helpers.timer(expire_in: 20)
  begin
    TCPSocket.open(selenium_host, selenium_port)
  rescue StandardError
    if timer.expired?
      raise 'Selenium is not running. ' \
          "You can run a selenium server easily with: \n" \
          '  $ docker-compose up -d selenium_chrome'
    else
      puts 'Waiting for Selenium docker instance...'
      sleep 1
      retry
    end
  end
end

def selenium_gte?(version)
  defined?(Selenium::WebDriver::VERSION) && (Selenium::WebDriver::VERSION.to_f >= version)
end

Capybara.register_driver :selenium_chrome_remote do |app|
  ensure_selenium_running!

  url = "http://#{selenium_host}:#{selenium_port}/wd/hub"
  browser_options = ::Selenium::WebDriver::Chrome::Options.new

  Capybara::Selenium::Driver.new app,
                                 browser: :remote,
                                 desired_capabilities: :chrome,
                                 options: browser_options,
                                 url: url
end

CHROME_REMOTE_DRIVER = :selenium_chrome_remote

module TestSessions
  Chrome = Capybara::Session.new(CHROME_REMOTE_DRIVER, TestApp)
end

skipped_tests = %i[response_headers status_code trigger download]

Capybara::SpecHelper.run_specs TestSessions::Chrome, CHROME_REMOTE_DRIVER.to_s, capybara_skip: skipped_tests do |example|
  case example.metadata[:full_description]
  when 'Capybara::Session selenium_chrome_remote #attach_file with multipart form should not break when using HTML5 multiple file input uploading multiple files',
       'Capybara::Session selenium_chrome_remote #attach_file with multipart form should fire change once for each set of files uploaded',
       'Capybara::Session selenium_chrome_remote #attach_file with multipart form should fire change once when uploading multiple files from empty'
    pending "Selenium with Remote Chrome doesn't support multiple file upload" unless selenium_gte?(3.14)
  when /node #right_click delay should delay the mouse up/
    skip "Legacy selenium doesn't support separate right button down/up" if ENV['W3C'] == 'false'
  end
end

RSpec.describe 'Capybara::Session with remote Chrome' do
  include Capybara::SpecHelper
  ['Capybara::Session', 'Capybara::Node', Capybara::RSpecMatchers].each do |examples|
    include_examples examples, TestSessions::Chrome, CHROME_REMOTE_DRIVER
  end

  it 'is considered to be chrome' do
    expect(session.driver.browser.browser).to eq :chrome
  end

  describe 'log access' do
    before { skip 'Only makes sense in W3C mode' if ENV['W3C'] == 'false' }

    it 'does not error when getting log types' do
      skip if Gem::Version.new(session.driver.browser.capabilities['chrome']['chromedriverVersion'].split[0]) < Gem::Version.new('75.0.3770.90')
      expect do
        session.driver.browser.manage.logs.available_types
      end.not_to raise_error
    end

    it 'does not error when getting logs' do
      expect do
        session.driver.browser.manage.logs.get(:browser)
      end.not_to raise_error
    end
  end
end
