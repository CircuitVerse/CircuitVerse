# [Coveralls Reborn](https://coveralls.io) for Ruby [![Coverage Status](https://coveralls.io/repos/github/tagliala/coveralls-ruby-reborn/badge.svg?branch=main)](https://coveralls.io/github/tagliala/coveralls-ruby-reborn?branch=main) ![Build Status](https://github.com/tagliala/coveralls-ruby-reborn/actions/workflows/ruby.yml/badge.svg) [![Gem Version](https://badge.fury.io/rb/coveralls_reborn.svg)](https://badge.fury.io/rb/coveralls_reborn)

### [Read the docs &rarr;](https://docs.coveralls.io/ruby-and-rails)

An up-to-date fork of [lemurheavy/coveralls-ruby](https://github.com/lemurheavy/coveralls-ruby)

Add to your `Gemfile`:

```rb
gem 'coveralls_reborn', '~> 0.26.0', require: false
```

### GitHub Actions

Psst... you don't need this gem on GitHub Actions.

For a Rails application, just add

```rb
gem 'simplecov-lcov', '~> 0.8.0'
```

to your `Gemfile` and

```rb
require 'simplecov'

SimpleCov.start 'rails' do
  if ENV['CI']
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end

    formatter SimpleCov::Formatter::LcovFormatter
  end

  add_filter %w[version.rb initializer.rb]
end
```

at the top of `spec_helper.rb` / `rails_helper.rb` / `test_helper.rb`.

Then follow instructions at [Coveralls GitHub Action](https://github.com/marketplace/actions/coveralls-github-action)
