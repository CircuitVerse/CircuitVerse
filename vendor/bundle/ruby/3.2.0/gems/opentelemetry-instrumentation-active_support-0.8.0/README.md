# OpenTelemetry ActiveSupport Instrumentation

The Active Support instrumentation is a community-maintained instrumentation for the Active Support portion of the [Ruby on Rails][rails-home] web-application framework.

## How do I get started?

Install the gem using:

```console

gem install opentelemetry-instrumentation-active_support

```

Or, if you use [bundler][bundler-home], include `opentelemetry-instrumentation-active_support` in your `Gemfile`.

## Usage

To use the instrumentation, call `use` with the name of the instrumentation and subscribe
to desired ActiveSupport notification:

```ruby

OpenTelemetry::SDK.configure do |c|
  c.use 'OpenTelemetry::Instrumentation::ActiveSupport'
end

tracer = OpenTelemetry.tracer_provider.tracer('my_app_or_gem', '0.1.0')
::OpenTelemetry::Instrumentation::ActiveSupport.subscribe(tracer, 'bar.foo')

```

Alternatively, you can also call `use_all` to install all the available instrumentation.

```ruby

OpenTelemetry::SDK.configure do |c|
  c.use_all
end

```

## Examples

Example usage can be seen in the `./example/trace_demonstration.rb` file [here](https://github.com/open-telemetry/opentelemetry-ruby-contrib/blob/main/instrumentation/active_support/example/trace_demonstration.rb)

## How can I get involved?

The `opentelemetry-instrumentation-active_support` gem source is [on github][repo-github], along with related gems including `opentelemetry-api` and `opentelemetry-sdk`.

The OpenTelemetry Ruby gems are maintained by the OpenTelemetry Ruby special interest group (SIG). You can get involved by joining us on our [GitHub Discussions][discussions-url], [Slack Channel][slack-channel] or attending our weekly meeting. See the [meeting calendar][community-meetings] for dates and times. For more information on this and other language SIGs, see the OpenTelemetry [community page][ruby-sig].

## License

The `opentelemetry-instrumentation-active_support` gem is distributed under the Apache 2.0 license. See [LICENSE][license-github] for more information.

[rails-home]: https://rubyonrails.org
[bundler-home]: https://bundler.io
[repo-github]: https://github.com/open-telemetry/opentelemetry-ruby
[license-github]: https://github.com/open-telemetry/opentelemetry-ruby-contrib/blob/main/LICENSE
[ruby-sig]: https://github.com/open-telemetry/community#ruby-sig
[community-meetings]: https://github.com/open-telemetry/community#community-meetings
[slack-channel]: https://cloud-native.slack.com/archives/C01NWKKMKMY
[discussions-url]: https://github.com/open-telemetry/opentelemetry-ruby/discussions
