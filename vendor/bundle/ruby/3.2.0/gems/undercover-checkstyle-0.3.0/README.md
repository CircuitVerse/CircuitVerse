# undercover-checkstyle

![Actions Demo](https://i.gyazo.com/881890dcba76cf30a8db86d9635ba38a.png)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'undercover-checkstyle'
```

And then execute:

    $ bundle install

## Usage

[Setting up required LCOV reporting](https://github.com/grodowski/undercover#setting-up-required-lcov-reporting)

```
bundle exec undercover-checkstyle
```

### GitHub Actions Example

*reviewdog.yml*
```yaml
runner:
  undercover:
    cmd: bundle exec undercover-checkstyle --compare origin/master
    level: warning
    format: checkstyle
```

*.github/workflows/ruby.yml*
```yaml
name: Ruby

on:
  pull_request:

jobs:
  rspec:
    runs-on: ubuntu-latest

    env:
      RUBYOPT: -EUTF-8

    steps:
      - uses: actions/checkout@v2

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1

      - name: Bundle install
        run: |
          bundle config path vendor/bundle
          bundle install --jobs 4 --retry 3

      - name: Rspec
        run: bundle exec rspec

      - name: Setup reviewdog
        run: |
          mkdir -p $HOME/bin && curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b $HOME/bin
          echo ::add-path::$HOME/bin
          echo ::add-path::$(go env GOPATH)/bin # for Go projects

      - name: Run reviewdog
        env:
          REVIEWDOG_GITHUB_API_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          git fetch
          reviewdog -reporter=github-pr-review -runners=undercover
```

## Thanks

- [grodowski/undercover: Actionable code coverage \- detects untested code blocks in recent changes](https://github.com/grodowski/undercover)
