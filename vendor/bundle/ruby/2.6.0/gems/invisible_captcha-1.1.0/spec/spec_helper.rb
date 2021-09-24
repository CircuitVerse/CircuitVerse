# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require 'rspec/rails'
require 'invisible_captcha'

RSpec.configure do |config|
  if Rails.version >= '5.2'
    config.include ActionDispatch::ContentSecurityPolicy::Request, type: :helper
  end
  config.disable_monkey_patching!
  config.order = :random
  config.expect_with :rspec
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

# Rails 4.2 call `initialize` inside `recycle!`. However Ruby 2.6 doesn't allow calling `initialize` twice.
# More info: https://github.com/rails/rails/issues/34790
if RUBY_VERSION >= "2.6.0" && Rails.version < "5"
  module ActionController
    class TestResponse < ActionDispatch::TestResponse
      def recycle!
        @mon_mutex_owner_object_id = nil
        @mon_mutex = nil
        initialize
      end
    end
  end
end
