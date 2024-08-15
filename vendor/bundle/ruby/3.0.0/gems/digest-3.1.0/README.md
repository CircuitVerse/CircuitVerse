# Digest

![CI](https://github.com/ruby/digest/workflows/CI/badge.svg?branch=master&event=push)

This module provides a framework for message digest libraries.

You may want to look at OpenSSL::Digest as it supports more algorithms.

A cryptographic hash function is a procedure that takes data and returns a fixed bit string: the hash value, also known as _digest_. Hash functions are also called one-way functions, it is easy to compute a digest from a message, but it is infeasible to generate a message from a digest.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'digest'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install digest

## Usage

```ruby
require 'digest'

# Compute a complete digest
Digest::SHA256.digest 'message'       #=> "\xABS\n\x13\xE4Y..."

sha256 = Digest::SHA256.new
sha256.digest 'message'               #=> "\xABS\n\x13\xE4Y..."

# Other encoding formats
Digest::SHA256.hexdigest 'message'    #=> "ab530a13e459..."
Digest::SHA256.base64digest 'message' #=> "q1MKE+RZFJgr..."

# Compute digest by chunks
md5 = Digest::MD5.new
md5.update 'message1'
md5 << 'message2'                     # << is an alias for update

md5.hexdigest                         #=> "94af09c09bb9..."

# Compute digest for a file
sha256 = Digest::SHA256.file 'testfile'
sha256.hexdigest
```

Additionally digests can be encoded in "bubble babble" format as a sequence of consonants and vowels which is more recognizable and comparable than a hexadecimal digest.

```ruby
require 'digest/bubblebabble'

Digest::SHA256.bubblebabble 'message' #=> "xopoh-fedac-fenyh-..."
```

See the bubble babble specification at http://web.mit.edu/kenta/www/one/bubblebabble/spec/jrtrjwzi/draft-huima-01.txt.

## Digest algorithms

Different digest algorithms (or hash functions) are available:

```
MD5::
 See RFC 1321 The MD5 Message-Digest Algorithm
RIPEMD-160::
  As Digest::RMD160.
  See http://homes.esat.kuleuven.be/~bosselae/ripemd160.html.
SHA1::
  See FIPS 180 Secure Hash Standard.
SHA2 family::
  See FIPS 180 Secure Hash Standard which defines the following algorithms:
 SHA512
 SHA384
 SHA256
```

The latest versions of the FIPS publications can be found here: http://csrc.nist.gov/publications/PubsFIPS.html.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ruby/digest.

## License

The gem is available as open source under the terms of the [2-Clause BSD License](https://opensource.org/licenses/BSD-2-Clause).
