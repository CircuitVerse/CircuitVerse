# yard-solargraph

A YARD extension for documenting Solargraph tags.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add yard-solargraph
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install yard-solargraph
```

## Usage

To include the plugin when you generate yardocs from the command line:

    yardoc --plugin yard-solargraph

To ensure that the plugin gets included when generating yardocs for gems:

1. Add yard-solargraph to your gemspec
2. Create a `.yardopts` file in your gem's root directory with the `plugin` option:
   ```
   --plugin yard-solargraph
   ```

## Additional Tags

The plugin adds two tags to your YARD documentation: `@generic` and `@yieldreceiver`.

### @generic

Use the `@generic` tag to reference parametrized types.

```ruby
# @generic T
class Example
  # @param [generic<T>]
  def initialize value
    @value = value
  end

  # @return [generic<T>]
  attr_reader :value
end

# @return [Example<String>]
def string_example
  Example.new('test')
end

string_example.value # => Solargraph will infer that #value returns a String
```

### @yieldreceiver

Use the `@yieldreceiver` tag to document the type of receiver that a method will use to evaluate a block.

```ruby
# @yieldreceiver [Array]
def eval_in_array &block
  [].instance_eval &block
end

eval_in_array do
  length # => Solargraph will infer that this is an Array#length call
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/yard-solargraph.
