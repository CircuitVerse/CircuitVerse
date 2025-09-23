# glob

[![Tests](https://github.com/fnando/glob/workflows/ruby-tests/badge.svg)](https://github.com/fnando/glob)
[![Code Climate](https://codeclimate.com/github/fnando/glob/badges/gpa.svg)](https://codeclimate.com/github/fnando/glob)
[![Gem](https://img.shields.io/gem/v/glob.svg)](https://rubygems.org/gems/glob)
[![Gem](https://img.shields.io/gem/dt/glob.svg)](https://rubygems.org/gems/glob)

Create a list of hash paths that match a given pattern. You can also generate a
hash with only the matching paths.

## Installation

```bash
gem install glob
```

Or add the following line to your project's Gemfile:

```ruby
gem "glob"
```

## Usage

There are two types of paths: `include` and `exclude`.

- The `include` path adds that node to the new hash.
- The `exclude` path is the one started by `!`, and will prevent that path from
  being added.

Rules may also have groups. Let's say you want to target `en.*` and `pt.*`; you
case set `{en,pt}.*` rather than having two separate rules.

The latest rules have more precedence; that means that if you have the rule
`*.messages.*`, then add a following rule as `!*.messages.bye`, all
`*.messages.*` but `*.messages.bye` will be included.

```ruby
glob = Glob.new(
  site: {
    settings: {
      name: "Site name",
      url: "https://example.com"
    }
  },
  user: {
    settings: {
      name: "User name"
    }
  }
)

glob << "*.settings.*"

glob.paths
#=> ["site.settings.name", "site.settings.url", "user.settings.name"]

glob.to_h
#=> {
#=>   site: {
#=>     settings: {
#=>       name: "Site name"
#=>     }
#=>   },
#=>   user: {
#=>     settings: {
#=>       name: "User name"
#=>     }
#=>   }
#=> }
```

Notice that the return result will have symbolized keys.

If the key contain dots, then the result will use `\\.` as the escape sequence.
Similarly, you need to escape keys with dots when filtering results.

```ruby
glob = Glob.new(
  formats: {
    ".txt" => "Text",
    ".json" => "JSON",
    ".rb" => "Ruby"
  }
)

glob << "*"

glob.paths
#=> ["formats.\\.json", "formats.\\.rb", "formats.\\.txt"]

glob.to_h
#=> {:formats=>{:".json"=>"JSON", :".rb"=>"Ruby", :".txt"=>"Text"}}

# Remove all existing matchers
glob.matchers.clear

glob << "formats.\\.rb"

glob.paths
#=> ["formats.\\.rb"]

glob.to_h
#=> {:formats=>{:".rb"=>"Ruby"}}
```

You can set new keys by using `.set(path, value)`:

```ruby
glob = Glob.new
glob << "*"
glob.set "a.b.c", "hello"

glob.to_h
#=> {:a=>{:b=>{:c=>"hello"}}}

glob.paths
#=> ["a.b.c"]

# The non-hash value will be replaced in case the new path overlaps it
glob.set "a.b.c.d.e", "hello"

glob.to_h
#=> {:a=>{:b=>{:c=>{:d=>{:e=>"hello"}}}}}

glob.paths
#=> ["a.b.c.d.e"]
```

## Maintainer

- [Nando Vieira](https://github.com/fnando)

## Contributors

- https://github.com/fnando/glob/contributors

## Contributing

For more details about how to contribute, please read
https://github.com/fnando/glob/blob/main/CONTRIBUTING.md.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT). A copy of the license can be
found at https://github.com/fnando/glob/blob/main/LICENSE.md.

## Code of Conduct

Everyone interacting in the glob project's codebases, issue trackers, chat rooms
and mailing lists is expected to follow the
[code of conduct](https://github.com/fnando/glob/blob/main/CODE_OF_CONDUCT.md).
