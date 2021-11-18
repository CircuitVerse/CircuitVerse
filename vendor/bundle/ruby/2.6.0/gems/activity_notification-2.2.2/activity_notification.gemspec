$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "activity_notification/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = "activity_notification"
  s.version       = ActivityNotification::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Shota Yamazaki"]
  s.email         = ["shota.yamazaki.8@gmail.com"]
  s.homepage      = "https://github.com/simukappu/activity_notification"
  s.summary       = "Integrated user activity notifications for Ruby on Rails"
  s.description   = "Integrated user activity notifications for Ruby on Rails. Provides functions to configure multiple notification targets and make activity notifications with notifiable models, like adding comments, responding etc."
  s.license       = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 2.1.0'

  s.add_dependency 'railties', '>= 5.0.0', '< 6.2'
  s.add_dependency 'i18n', '>= 0.5.0'
  s.add_dependency 'jquery-rails', '>= 3.1.1'
  s.add_dependency 'swagger-blocks', '>= 3.0.0'

  s.add_development_dependency 'puma', '>= 3.12.0'
  s.add_development_dependency 'sqlite3', '>= 1.3.13'
  s.add_development_dependency 'mysql2', '>= 0.5.2'
  s.add_development_dependency 'pg', '>= 1.0.0'
  s.add_development_dependency 'mongoid', '>= 4.0.0'
  s.add_development_dependency 'dynamoid', '3.1.0'
  s.add_development_dependency 'rspec-rails', '>= 3.8.0'
  s.add_development_dependency 'factory_bot_rails', '>= 4.11.0', '< 5.0.0'
  s.add_development_dependency 'simplecov', '~> 0'
  s.add_development_dependency 'yard', '>= 0.9.16'
  s.add_development_dependency 'yard-activesupport-concern', '>= 0.0.1'
  s.add_development_dependency 'devise', '>= 4.5.0'
  s.add_development_dependency 'devise_token_auth', '>= 1.1.3'
  s.add_development_dependency 'mongoid-locker', '>=  2.0.0'
  s.add_development_dependency 'aws-sdk-sns', '~> 1'
  s.add_development_dependency 'slack-notifier', '>= 1.5.1'
end
