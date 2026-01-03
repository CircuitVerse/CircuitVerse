# simplecov-lcov

Custom SimpleCov formatter to generate a lcov style coverage.

[![Build Status](https://travis-ci.org/fortissimo1997/simplecov-lcov.svg?branch=master)](https://travis-ci.org/fortissimo1997/simplecov-lcov)
[![Coverage Status](https://img.shields.io/coveralls/fortissimo1997/simplecov-lcov.svg)](https://coveralls.io/r/fortissimo1997/simplecov-lcov)
[![Gem Version](https://badge.fury.io/rb/simplecov-lcov.svg)](http://badge.fury.io/rb/simplecov-lcov)
[![Inline docs](http://inch-ci.org/github/fortissimo1997/simplecov-lcov.svg?branch=master)](http://inch-ci.org/github/fortissimo1997/simplecov-lcov)
[![Code Climate](https://codeclimate.com/github/fortissimo1997/simplecov-lcov.png)](https://codeclimate.com/github/fortissimo1997/simplecov-lcov)
[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/fortissimo1997/simplecov-lcov/badges/quality-score.png?b=master)](https://scrutinizer-ci.com/g/fortissimo1997/simplecov-lcov/?branch=master)

## Usage

#### Output report per file.

```Ruby
  require 'simplecov'
  require 'simplecov-lcov'
  SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
  SimpleCov.start
```

#### Output report as single file.

```Ruby
  require 'simplecov'
  require 'simplecov-lcov'
  SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
  SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
  SimpleCov.start
```

Other available configuration options for single file report:

```Ruby
  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.output_directory = 'your/path' # default: "coverage/lcov"
    c.lcov_file_name = 'lcov.info' # default: "YOUR_PROJECT_NAME.lcov"
    c.single_report_path = 'your/path/lcov.info'
  end
```

## Contributing to simplecov-lcov

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2014 fortissimo1997. See LICENSE.txt for
