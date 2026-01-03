source "https://rubygems.org"

gemspec

gem "pry"

# Hinting at development dependencies
# Prevents bundler from taking a long-time to resolve
group :development, :test do
  gem "activerecord-import"
  gem "bootsnap", require: false
  gem "builder"
  gem "listen", "~> 3.0.8"
  gem "rspec"
  # Hound only supports certain versions of Rubocop -- 1.22.1 is currently the most recent one supported.
  gem "rubocop", "1.22.1", require: false
  gem "rubocop-rails"
  gem "sprockets", "3.7.2"
end
