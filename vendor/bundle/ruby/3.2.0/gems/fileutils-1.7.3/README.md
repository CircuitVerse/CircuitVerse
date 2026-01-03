# FileUtils

Namespace for several file utility methods for copying, moving, removing, etc.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fileutils'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fileutils

## Usage

Just call `FileUtils` methods. For example:

```ruby
FileUtils.mkdir("somedir")
# => ["somedir"]

FileUtils.cd("/usr/bin")
FileUtils.pwd
# => "/usr/bin"
```

You can find a full method list in the [documentation](https://docs.ruby-lang.org/en/master/FileUtils.html).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ruby/fileutils.

## License

The gem is available as open source under the terms of the [2-Clause BSD License](https://opensource.org/licenses/BSD-2-Clause).
