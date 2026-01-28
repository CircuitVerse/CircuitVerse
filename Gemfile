source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# -------------------------------------------------
# Core Framework
# -------------------------------------------------
gem "rails", "~> 8.0.0"
gem "puma", "~> 6.4"
gem "pg", "~> 1.6.1"
gem "bootsnap", require: false

# -------------------------------------------------
# Assets & Frontend
# -------------------------------------------------
gem "sass-rails", "~> 6.0"
gem "sassc-rails"
gem "terser"
gem "jquery-rails"
gem "coffee-rails", "~> 5.0"
gem "select2-rails"
gem "turbolinks", "~> 5"
gem "font-awesome-sass", "~> 5.13.1"

# -------------------------------------------------
# Authentication & Authorization
# -------------------------------------------------
gem "devise"
gem "pundit"
gem "recaptcha"

# OmniAuth
gem "omniauth"
gem "omniauth-facebook"
gem "omniauth-github"
gem "omniauth-gitlab"
gem "omniauth-google-oauth2"
gem "omniauth-microsoft-office365"
gem "omniauth-rails_csrf_protection"

# SAML
gem "devise_saml_authenticatable"

# -------------------------------------------------
# Background Jobs & Caching
# -------------------------------------------------
gem "sidekiq"
gem "redis", "~> 4.6"
gem "hiredis"

# -------------------------------------------------
# File Uploads & Storage
# -------------------------------------------------
gem "carrierwave", "~> 3.0"
gem "aws-sdk-rails"
gem "aws-sdk-s3", "~> 1.208"
gem "image_processing", "~> 1.12"

# -------------------------------------------------
# Pagination & Search
# -------------------------------------------------
gem "will_paginate", "~> 4.0.1"
gem "will_paginate-bootstrap"
gem "pg_search"
gem "friendly_id", "~> 5.5.1"
gem "geocoder"
gem "country_select", "~> 8.0"

# -------------------------------------------------
# Admin & CMS
# -------------------------------------------------
gem "rails_admin", [">= 3.0.0.rc3", "< 4"]
gem "commontator", "~> 7.0.0"

# -------------------------------------------------
# API & Serialization
# -------------------------------------------------
gem "jbuilder", "~> 2.11"
gem "jsonapi-serializer"
gem "oj", "~> 3.15"

# -------------------------------------------------
# Notifications & Emails
# -------------------------------------------------
gem "noticed", "~> 1.6"
gem "mailkick", "~> 0.4.3"
gem "premailer-rails", "~> 1.11", ">= 1.11.1"
gem "webpush"
gem "invisible_captcha", "~> 2.0"

# -------------------------------------------------
# Analytics & Monitoring
# -------------------------------------------------
gem "ahoy_matey"
gem "sentry-ruby"
gem "sentry-rails"
gem "sentry-sidekiq", "~> 5.17"

# -------------------------------------------------
# Feature Flags
# -------------------------------------------------
gem "flipper-redis"
gem "flipper-ui"

# -------------------------------------------------
# Internationalization
# -------------------------------------------------
gem "rails-i18n", "~> 8.0.0"
gem "i18n-js"

# -------------------------------------------------
# Utilities
# -------------------------------------------------
gem "meta-tags"
gem "inline_svg"
gem "jwt"
gem "http", "~> 4.4"
gem "rack-attack"
gem "strong_migrations"
gem "rails-data-migrations", github: "notarize/rails-data-migrations"
gem "sitemap_generator"
gem "language_filter"
gem "hirb"
gem "kt-paperclip"
gem "rails_autolink"

# -------------------------------------------------
# CircuitVerse Custom Gems
# -------------------------------------------------
gem "disposable_mail", github: "CircuitVerse/disposable_email"
gem "simple_discussion", github: "CircuitVerse/simple_discussion"

# -------------------------------------------------
# OpenTelemetry
# -------------------------------------------------
gem "opentelemetry-sdk", "~> 1.8"
gem "opentelemetry-exporter-otlp", "~> 0.30.0"
gem "opentelemetry-instrumentation-rails"
gem "opentelemetry-instrumentation-active_record"
gem "opentelemetry-instrumentation-active_support"
gem "opentelemetry-instrumentation-sidekiq"
gem "opentelemetry-instrumentation-redis"
gem "opentelemetry-instrumentation-rack"
gem "opentelemetry-instrumentation-http"

# -------------------------------------------------
# Maintenance & Performance
# -------------------------------------------------
gem "maintenance_tasks", "~> 2.3"
gem "stackprof"

# -------------------------------------------------
# Development & Test
# -------------------------------------------------
group :development, :test do
  gem "debug"
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails", "~> 8.0"
  gem "coveralls_reborn", "~> 0.29.0", require: false
  gem "pry-rails"
  gem "erb_lint", require: false
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end

group :test do
  gem "capybara", "~> 3.39"
  gem "capybara-playwright-driver"
  gem "rspec_junit_formatter"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "simplecov-lcov"
  gem "json-schema"
  gem "webmock"
  gem "percy-capybara"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.10"
  gem "web-console", ">= 3.3.0"
  gem "rails-erd"
  gem "bundler-audit", "~> 0.9.1"
  gem "lookbook", ">= 2.2.0"
  gem "database_consistency", require: false
end

# -------------------------------------------------
# Platform Specific
# -------------------------------------------------
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "rexml", ">= 3.3.9"
gem "observer", "~> 0.1.2"
gem "drb", "~> 2.2"
gem "concurrent-ruby", "1.3.5"
gem "mutex_m"
