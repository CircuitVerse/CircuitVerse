source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "paperclip", ">= 5.2.0"
gem 'hirb'
gem 'acts_as_votable','~> 0.12.0'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'
gem 'omniauth-microsoft-office365'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

gem 'devise'

gem 'commontator', '~> 5.0.0'

# To generate sitemap.xml
gem 'sitemap_generator'

gem 'jquery-rails'

# gem 'acts_as_votable', '~> 0.11.1'

gem 'carrierwave', '~> 1.0'

gem 'rails_admin', '~> 2.0'

# gem 'cancancan', '~>2.0'

gem 'sidekiq'
gem 'pg_search'
gem 'sunspot_rails'

# For home page pagination
gem 'will_paginate', '~> 3.1.1'
gem 'will_paginate-bootstrap'

gem 'country_select', '~> 4.0'
gem 'bootstrap-typeahead-rails'

# for authorization layer
gem 'pundit'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development


# Database

gem "pg", "~> 1.1.4"

gem 'meta-tags'

# Notifications
gem 'activity_notification'
gem 'serviceworker-rails'
gem 'webpush'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'pry-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'coveralls'
  gem 'rubocop-rspec', require: false
  gem 'erb_lint', require: false
end

group :test do
  gem 'rspec-rails', '~> 3.8'
  gem "rspec_junit_formatter"
  gem 'selenium-webdriver'
  gem 'capybara', '~> 2.13'
  gem 'shoulda-matchers'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rails-erd'
  gem 'rubocop'
  gem 'sunspot_solr'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
