source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "acts_as_votable", "~> 0.13.2"
gem "aws-sdk-rails"
gem "dotenv-rails", groups: %i[development test]
gem "hirb"
gem "kt-paperclip"
gem "language_filter"
gem "mailkick"
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
gem "puma", "~> 5.6"
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

gem "carrierwave", "~> 2.2"

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

gem "pg", "~> 1.4.3"

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

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem "coveralls_reborn", "~> 0.26.0", require: false
  gem "erb_lint", require: false
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
  gem "rspec-rails", "~> 5.1"
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end

group :test do
  gem "capybara", "~> 3.36"
  gem "json-schema"
  gem "rspec_junit_formatter"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "webdrivers", "~> 5.0", require: false
  gem "webmock"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "listen", ">= 3.0.5", "< 3.8"
  gem "web-console", ">= 3.3.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "rails-erd"
  gem "rubocop"
  gem "spring"
  gem "sunspot_solr"
  gem "bundler-audit", "~> 0.9.1"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# mails
gem "premailer-rails", "~> 1.11", ">= 1.11.1"

gem "bugsnag", "~> 6.24"

gem "invisible_captcha", "~> 2.0"

gem "newrelic_rpm", "~> 8.14"

gem "oj", "~> 3.13"

gem "hairtrigger", "~> 0.2.25"

# Used for rate limiting
gem "rack-attack"

gem "jsbundling-rails", "~> 1.0"

gem "sassc-rails"
gem "stimulus-rails", "~> 1.0"

gem "noticed", "~> 1.6"
