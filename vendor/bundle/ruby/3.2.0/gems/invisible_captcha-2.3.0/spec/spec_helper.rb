# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require 'simplecov'
if ENV['CI']
  require 'simplecov-cobertura'
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end
SimpleCov.start

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require 'rspec/rails'
require 'invisible_captcha'

RSpec.configure do |config|
  config.include ActionDispatch::ContentSecurityPolicy::Request, type: :helper
  config.disable_monkey_patching!
  config.order = :random
  config.expect_with :rspec
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
