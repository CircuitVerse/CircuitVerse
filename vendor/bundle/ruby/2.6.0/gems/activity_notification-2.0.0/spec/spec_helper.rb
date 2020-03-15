ENV["RAILS_ENV"] ||= "test"

require 'bundler/setup'
Bundler.setup

require 'simplecov'
require 'coveralls'
require 'rails'
Coveralls.wear!
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start('rails') do
  add_filter '/spec/'
  add_filter '/lib/generators/templates/'
  add_filter '/lib/activity_notification/version.rb'
  if Rails::VERSION::MAJOR >= 5
    skip_token_tag = 'except-rails5-plus'
  else
    skip_token_tag = 'only-rails5-plus'
    add_filter '/app/channels/activity_notification/'
  end
  if Gem::Version.new("5.1.6") <= Rails.gem_version && Rails.gem_version < Gem::Version.new("5.2.2")
    skip_token_tag += '#only-rails-without-callback-issue'
  else
    skip_token_tag += '#only-rails-with-callback-issue'
  end
  if ENV['AN_ORM'] == 'mongoid'
    add_filter '/lib/activity_notification/orm/active_record'
    add_filter '/lib/activity_notification/orm/dynamoid'
  elsif ENV['AN_ORM'] == 'dynamoid'
    add_filter '/lib/activity_notification/orm/active_record'
    add_filter '/lib/activity_notification/orm/mongoid'
    skip_token_tag += '#except-dynamoid'
  else
    add_filter '/lib/activity_notification/orm/mongoid'
    add_filter '/lib/activity_notification/orm/dynamoid'
  end
  skip_token skip_token_tag
end

# Dummy application
require 'rails_app/config/environment'

require 'rspec/rails'
require 'ammeter/init'
require "action_cable/testing/rspec" if Rails::VERSION::MAJOR == 5
require 'factory_bot_rails'
require 'activity_notification'

Dir[Rails.root.join("../../spec/support/**/*.rb")].each { |file| require file }

def clean_database
  [ActivityNotification::Notification, ActivityNotification::Subscription, Comment, Article, Admin, User].each do |model_class|
    model_class.delete_all
  end
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.before(:all) do
    FactoryBot.reload
    clean_database
  end
  config.include Devise::Test::ControllerHelpers, type: :controller
end
