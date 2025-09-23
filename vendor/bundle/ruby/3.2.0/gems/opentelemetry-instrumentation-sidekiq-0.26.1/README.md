# OpenTelemetry Sidekiq Instrumentation

The Sidekiq instrumentation is a community-maintained instrumentation for the [Sidekiq][sidekiq-home] Ruby jobs system.

## How do I get started?

Install the gem using:

```console
gem install opentelemetry-instrumentation-sidekiq
```

Or, if you use [bundler][bundler-home], include `opentelemetry-instrumentation-sidekiq` in your `Gemfile`.

## Usage

To use the instrumentation, call `use` with the name of the instrumentation:

```ruby
OpenTelemetry::SDK.configure do |c|
  c.use 'OpenTelemetry::Instrumentation::Sidekiq'
end
```

Alternatively, you can also call `use_all` to install all the available instrumentation.

```ruby
OpenTelemetry::SDK.configure do |c|
  c.use_all
end
```

## Examples

Example usage can be seen in the `./example/sidekiq.rb` file [here](https://github.com/open-telemetry/opentelemetry-ruby-contrib/blob/main/instrumentation/sidekiq/example/sidekiq.rb)

## Development

You'll need Redis installed locally to run the test suite. Once you've
installed it, it will start and stop automatically when you run `rake`.

```console
redis-server test/redis.conf
```

## How can I get involved?

The `opentelemetry-instrumentation-sidekiq` gem source is [on github][repo-github], along with related gems including `opentelemetry-api` and `opentelemetry-sdk`.

The OpenTelemetry Ruby gems are maintained by the OpenTelemetry Ruby special interest group (SIG). You can get involved by joining us on our [GitHub Discussions][discussions-url], [Slack Channel][slack-channel] or attending our weekly meeting. See the [meeting calendar][community-meetings] for dates and times. For more information on this and other language SIGs, see the OpenTelemetry [community page][ruby-sig].

## License

The `opentelemetry-instrumentation-sidekiq` gem is distributed under the Apache 2.0 license. See [LICENSE][license-github] for more information.

[sidekiq-home]: https://github.com/mperham/sidekiq
[bundler-home]: https://bundler.io
[repo-github]: https://github.com/open-telemetry/opentelemetry-ruby
[license-github]: https://github.com/open-telemetry/opentelemetry-ruby-contrib/blob/main/LICENSE
[ruby-sig]: https://github.com/open-telemetry/community#ruby-sig
[community-meetings]: https://github.com/open-telemetry/community#community-meetings
[slack-channel]: https://cloud-native.slack.com/archives/C01NWKKMKMY
[discussions-url]: https://github.com/open-telemetry/opentelemetry-ruby/discussions
