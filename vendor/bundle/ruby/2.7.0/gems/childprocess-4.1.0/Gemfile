source 'http://rubygems.org'

# Specify your gem's dependencies in child_process.gemspec
gemspec

# Used for local development/testing only
gem 'rake'

gem 'ffi' if ENV['CHILDPROCESS_POSIX_SPAWN'] == 'true' || Gem.win_platform?
