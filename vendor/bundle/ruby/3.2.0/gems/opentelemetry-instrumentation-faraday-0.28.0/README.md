# OpenTelemetry Faraday Instrumentation

The OpenTelemetry Faraday Ruby gem is a community maintained instrumentation for [Faraday][faraday-home]. This is an HTTP client library that provides a common interface over many adaptors, such as Net::HTTP.

## How do I get started?

Install the gem using:

```console
gem install opentelemetry-instrumentation-faraday
```

Or, if you use [bundler][bundler-home], include `opentelemetry-instrumentation-faraday` in your `Gemfile`.

## Usage

To install the instrumentation, call `use` with the name of the instrumentation.

```ruby
OpenTelemetry::SDK.configure do |c|
  c.use 'OpenTelemetry::Instrumentation::Faraday', {
    enable_internal_instrumentation: false
  }
end
```

Alternatively, you can also call `use_all` to install all the available instrumentation.

```ruby
OpenTelemetry::SDK.configure do |c|
  c.use_all
end
```

### Configuration options
This instrumentation offers the following configuration options: 
* `enable_internal_instrumentation` (default: `false`): When set to `true`, any spans with 
 span kind of `internal` are included in traces.

## Examples

Example usage of faraday can be seen in the [`./example/faraday.rb` file](https://github.com/open-telemetry/opentelemetry-ruby-contrib/blob/main/instrumentation/faraday/example/faraday.rb)

## How can I get involved?

The `opentelemetry-instrumentation-faraday` gem source is [on github][repo-github], along with related gems including `opentelemetry-api` and `opentelemetry-sdk`.

The OpenTelemetry Ruby gems are maintained by the OpenTelemetry Ruby special interest group (SIG). You can get involved by joining us on our [GitHub Discussions][discussions-url], [Slack Channel][slack-channel] or attending our weekly meeting. See the [meeting calendar][community-meetings] for dates and times. For more information on this and other language SIGs, see the OpenTelemetry [community page][ruby-sig].

## License

Apache 2.0 license. See [LICENSE][license-github] for more information.

[faraday-home]: https://github.com/lostisland/faraday
[bundler-home]: https://bundler.io
[repo-github]: https://github.com/open-telemetry/opentelemetry-ruby
[license-github]: https://github.com/open-telemetry/opentelemetry-ruby-contrib/blob/main/LICENSE
[ruby-sig]: https://github.com/open-telemetry/community#ruby-sig
[community-meetings]: https://github.com/open-telemetry/community#community-meetings
[slack-channel]: https://cloud-native.slack.com/archives/C01NWKKMKMY
[discussions-url]: https://github.com/open-telemetry/opentelemetry-ruby/discussions

## HTTP semantic convention stability

In the OpenTelemetry ecosystem, HTTP semantic conventions have now reached a stable state. However, the initial Faraday instrumentation was introduced before this stability was achieved, which resulted in HTTP attributes being based on an older version of the semantic conventions.

To facilitate the migration to stable semantic conventions, you can use the `OTEL_SEMCONV_STABILITY_OPT_IN` environment variable. This variable allows you to opt-in to the new stable conventions, ensuring compatibility and future-proofing your instrumentation.

When setting the value for `OTEL_SEMCONV_STABILITY_OPT_IN`, you can specify which conventions you wish to adopt:

- `http` - Emits the stable HTTP and networking conventions and ceases emitting the old conventions previously emitted by the instrumentation.
- `http/dup` - Emits both the old and stable HTTP and networking conventions, enabling a phased rollout of the stable semantic conventions.
- Default behavior (in the absence of either value) is to continue emitting the old HTTP and networking conventions the instrumentation previously emitted.

During the transition from old to stable conventions, Faraday instrumentation code comes in three patch versions: `dup`, `old`, and `stable`. These versions are identical except for the attributes they send. Any changes to Faraday instrumentation should consider all three patches.

For additional information on migration, please refer to our [documentation](https://opentelemetry.io/docs/specs/semconv/non-normative/http-migration/).
