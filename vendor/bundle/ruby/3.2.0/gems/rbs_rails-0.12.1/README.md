# RBS Rails

RBS files generator for Ruby on Rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rbs_rails', require: false
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rbs_rails

## Usage

Run the following command. It generates `lib/tasks/rbs.rake`.

```console
$ bin/rails g rbs_rails:install
```

Then, the following three tasks are available.

* `rbs_rails:generate_rbs_for_models`: Generate RBS files for Active Record models
* `rbs_rails:generate_rbs_for_path_helpers`: Generate RBS files for path helpers
* `rbs_rails:all`: Execute all tasks of RBS Rails


### Install RBS for `rails` gem

You need to install `rails` gem's RBS files. I highly recommend using `rbs collection`.

1. Add `gem 'rails'` to your `Gemfile`.
1. Then execute the following commands
   ```console
   $ bundle install
   $ bundle exec rbs collection init
   $ bundle exec rbs collection install
   ```

### Steep integration

Put the following code as `Steepfile`.

```ruby
target :app do
  signature 'sig'

  check 'app'
end
```

That's all! Now you can check your Rails app statically with `steep check` command.

## Development

After checking out the repo, run `bin/setup` to install dependencies.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pocke/rbs_rails.

