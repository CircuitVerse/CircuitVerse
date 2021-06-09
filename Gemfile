source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "acts_as_votable", "~> 0.13.1"
gem "aws-sdk-rails"
gem "dotenv-rails", groups: %i[development test]
gem "hirb"
gem "language_filter"
gem "mailkick"
gem "omniauth"
gem "omniauth-facebook"
gem "omniauth-github"
gem "omniauth-google-oauth2"
gem "omniauth-microsoft-office365"
gem "paperclip", ">= 5.2.0"
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.0"
# Use Puma as the app server
gem "puma", "~> 5.3"
# Use SCSS for stylesheets
gem "sass-rails", "~> 5.0"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem "coffee-rails", "~> 5.0"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.11"

gem "devise"

gem "commontator", "~> 6.3.0"

# To generate sitemap.xml
gem "sitemap_generator"

gem "jquery-rails"

# gem 'acts_as_votable', '~> 0.11.1'

gem "carrierwave", "~> 2.1"

gem "rails_admin", "~> 2.1"

# gem 'cancancan', '~>2.0'

gem "pg_search"
gem "sidekiq"
gem "sunspot_rails"

# For home page pagination
gem "will_paginate", "~> 3.3.0"
gem "will_paginate-bootstrap"

gem "bootstrap-typeahead-rails"
gem "country_select", "~> 4.0"
gem "geocoder"

# for authorization layer
gem "pundit"

# for analytics
gem "ahoy_matey"
gem "i18n-js"

# for lti provider
gem "ims-lti", "~> 1.1.8"

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem "http"

# Database

gem "pg", "~> 1.2.3"

gem "meta-tags"

# Notifications
gem "activity_notification"
gem "serviceworker-rails"
gem "webpush"

gem "webpacker", "~> 5.x"

gem "bootsnap", require: false

gem "font-awesome-sass", "~> 5.13.1"

gem "disposable_mail", "~> 0.1"
gem "fast_jsonapi"
gem "flipper-redis"
gem "flipper-ui"
gem "friendly_id", "~> 5.4.1"
gem "inline_svg"
gem "jwt"
gem "rails-i18n", "~> 6.0.0"
gem "recaptcha"
gem "simple_discussion", "~> 1.2"
gem 'strong_migrations'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem "coveralls"
  gem "erb_lint", require: false
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rspec-rails", "~> 5.0"
end

group :test do
  gem "capybara", "~> 3.33"
  gem "json-schema"
  gem "rspec_junit_formatter"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "webdrivers", "~> 4.0"
  gem "webmock"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "listen", ">= 3.0.5", "< 3.4"
  gem "web-console", ">= 3.3.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "rails-erd"
  gem "rubocop"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "sunspot_solr"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# mails
gem "premailer-rails", "~> 1.11", ">= 1.11.1"

gem "bugsnag", "~> 6.18"

gem "invisible_captcha", "~> 1.1"

gem "newrelic_rpm", "~> 6.13"

gem "oj", "~> 3.11"

gem "hairtrigger", "~> 0.2.24"
