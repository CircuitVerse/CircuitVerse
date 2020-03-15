source 'https://rubygems.org'

gemspec

gem 'rails', '~> 5.2'

group :production do
  gem 'puma'
  gem 'pg'
  gem 'devise'
end

group :development do
  gem 'bullet'
end

group :test do
  gem 'rails-controller-testing'
  gem 'action-cable-testing'
  gem 'ammeter'
  gem 'timecop'
  gem 'coveralls', require: false
end

gem 'dotenv-rails', groups: [:development, :test]
