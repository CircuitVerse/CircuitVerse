source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "acts_as_votable", "~> 0.14.0"
gem "aws-sdk-rails"
gem "dotenv-rails", groups: %i[development test]
gem "hirb"
gem "kt-paperclip"
gem "language_filter"
gem "mailkick", "~> 0.4.3"
gem "omniauth"
gem "omniauth-facebook"
gem "omniauth-github"
gem "omniauth-gitlab"
gem "omniauth-google-oauth2"
gem "omniauth-microsoft-office365"
gem 'devise_saml_authenticatable'
gem 'omniauth-rails_csrf_protection'
gem "view_component"
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.0"
# Use Puma as the app server
gem "puma", "~> 6.3"
# Use SCSS for stylesheets
gem "sass-rails", "~> 6.0"
gem "terser"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem "coffee-rails", "~> 5.0"
gem "select2-rails"
gem 'redcarpet', '~> 3.3', '>= 3.3.4'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.11"

gem "devise"

gem "commontator", "~> 7.0.0"

# To generate sitemap.xml
gem "sitemap_generator"

gem "jquery-rails"

# gem 'acts_as_votable', '~> 0.11.1'

gem "carrierwave", "~> 3.0"

gem "rails_admin", [">= 3.0.0.rc3", "< 4"]

# gem 'cancancan', '~>2.0'

gem "pg_search"
gem "sidekiq"
gem "sunspot_rails"

# For home page pagination
gem "will_paginate", "~> 3.3.1"
gem "will_paginate-bootstrap"

gem "country_select", "~> 8.0"
gem "geocoder"

# for authorization layer
gem "pundit"

# for analytics
gem "ahoy_matey"
gem "i18n-js"

# for lti provider
gem "ims-lti", "~> 1.2", "< 2.0"

# Use Redis adapter to run Action Cable in production
gem "hiredis"
gem "redis", "~> 4.6"
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem "http"

# Database

gem "pg", "~> 1.5.3"

gem "meta-tags"

# Notifications
gem "webpush"

gem "bootsnap", require: false
gem "rexml"

gem "font-awesome-sass", "~> 5.13.1"

gem "disposable_mail", github: 'CircuitVerse/disposable_email'
gem "flipper-redis"
gem "flipper-ui"
gem "friendly_id", "~> 5.4.2"
gem "inline_svg"
gem "jsonapi-serializer"
gem "jwt"
gem "rails-i18n", "~> 7.0.3"
gem "recaptcha"
gem "simple_discussion", github: "CircuitVerse/simple_discussion"
gem "sprockets", "~> 4.1"
gem "strong_migrations"
gem 'rails-data-migrations'

# For Vite rails
gem 'vite_rails'

group :development, :test do
  # Adds support for debug
  gem "debug"
  # Adds support for Capybara system testing and selenium driver
  gem "coveralls_reborn", "~> 0.26.0", require: false
  gem "erb_lint", require: false
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
  gem "rspec-rails", "~> 6.0"
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rbs_rails"
  gem "steep"
  gem 'solargraph-rails', '~> 0.3.1'
end

group :test do
  gem "capybara", "~> 3.39"
  gem "json-schema"
  gem "rspec_junit_formatter"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "webmock"
  gem "simplecov"
  gem "simplecov-lcov"
  gem "undercover"
  gem "undercover-checkstyle"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "listen", ">= 3.0.5", "< 3.9"
  gem "web-console", ">= 3.3.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "rails-erd"
  gem "rubocop"
  gem "spring"
  gem "sunspot_solr"
  gem "bundler-audit", "~> 0.9.1"
  gem 'database_consistency', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# mails
gem "premailer-rails", "~> 1.11", ">= 1.11.1"

gem "bugsnag", "~> 6.24"

gem "invisible_captcha", "~> 2.0"

gem "newrelic_rpm", "~> 8.14"

gem "oj", "~> 3.15"

gem "hairtrigger", "~> 0.2.25"

# Used for rate limiting
gem "rack-attack"

gem "jsbundling-rails", "~> 1.0"

gem "sassc-rails"
gem "stimulus-rails", "~> 1.0"

gem "noticed", "~> 1.6"

# ActiveStorage AWS S3 + Variant Processing
gem "aws-sdk-s3", "~> 1.116"
gem "image_processing", "~> 1.12"
# Distributed Tracing OTEL ruby
gem "opentelemetry-sdk", "~> 1.2"
gem "opentelemetry-exporter-otlp", "~> 0.25.0"
gem "opentelemetry-instrumentation-active_job"
gem "opentelemetry-instrumentation-active_model_serializers"
gem "opentelemetry-instrumentation-active_record"
gem "opentelemetry-instrumentation-active_support"
gem "opentelemetry-instrumentation-aws_sdk"
gem "opentelemetry-instrumentation-concurrent_ruby"
gem "opentelemetry-instrumentation-faraday"
gem "opentelemetry-instrumentation-http"
gem "opentelemetry-instrumentation-net_http"
gem "opentelemetry-instrumentation-pg"
gem "opentelemetry-instrumentation-rack"
gem "opentelemetry-instrumentation-rails"
gem "opentelemetry-instrumentation-redis"
gem "opentelemetry-instrumentation-sidekiq"
gem "opentelemetry-instrumentation-action_pack"
gem "opentelemetry-instrumentation-action_view"

gem "maintenance_tasks", "~> 2.3"
