# OpenTelemetry ActionPack Instrumentation

The Action Pack instrumentation is a community-maintained instrumentation for the Action Pack portion of the [Ruby on Rails][rails-home] web-application framework.

## How do I get started?

Install the gem using:

```console
gem install opentelemetry-instrumentation-action_pack
```

Or, if you use [bundler][bundler-home], include `opentelemetry-instrumentation-action_pack` in your `Gemfile`.

## Usage

To use the instrumentation, call `use` with the name of the instrumentation:

```ruby
OpenTelemetry::SDK.configure do |c|
  c.use 'OpenTelemetry::Instrumentation::ActionPack'
end
```

Alternatively, you can also call `use_all` to install all the available instrumentation.

```ruby
OpenTelemetry::SDK.configure do |c|
  c.use_all
end
```

## Active Support Instrumentation

Earlier versions of this instrumentation relied on patching custom `dispatch` hooks from Rails's [Action Controller](https://github.com/rails/rails/blob/main/actionpack/lib/action_controller/metal.rb#L224) to extract request information.

This instrumentation now relies on `ActiveSupport::Notifications` and registers a custom Subscriber that listens to relevant events to modify the Rack span.

See the table below for details of what [Rails Framework Hook Events](https://guides.rubyonrails.org/active_support_instrumentation.html#action-controller) are recorded by this instrumentation:

| Event Name | Subscribe? | Creates Span? |  Notes |
| - | - | - | - |
| `process_action.action_controller` | :white_check_mark: | :x: | It modifies the existing Rack span |

## Semantic Conventions

This instrumentation generally uses [HTTP server semantic conventions](https://opentelemetry.io/docs/specs/semconv/http/http-spans/) to update the existing Rack span.

For Rails 7.1+, the span name is updated to match the HTTP method and route that was matched for the request using [`ActionDispatch::Request#route_uri_pattern`](https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-route_uri_pattern), e.g.: `GET /users/:id`

For older versions of Rails the span name is updated to match the HTTP method, controller, and action name that was the target of the request, e.g.: `GET /example/index`

> ![NOTE]: Users may override the `span_naming` option to default to Legacy Span Naming Behavior that uses the controller's class name and action in Ruby documentation syntax, e.g. `ExampleController#index`.

This instrumentation does not emit any custom attributes.

| Attribute Name | Type | Notes |
| - | - | - |
| `code.namespace` | String | `ActionController` class name |
| `code.function` | String | `ActionController` action name e.g. `index`, `show`, `edit`, etc... |
| `http.route` | String | (Rails 7.1+) the route that was matched for the request |
| `http.target` | String | The `request.filtered_path` |

### Error Handling for Action Controller

If an error is triggered by Action Controller (such as a 500 internal server error), Action Pack will typically employ the default `ActionDispatch::PublicExceptions.new(Rails.public_path)` as the `exceptions_app`, as detailed in the [documentation](https://guides.rubyonrails.org/configuring.html#config-exceptions-app).

The error object will be retained within `payload[:exception_object]`. Additionally, its storage in `request.env['action_dispatch.exception']` is contingent upon the configuration of `action_dispatch.show_exceptions` in Rails.

## Examples

Example usage can be seen in the [`./example/trace_demonstration.rb` file](https://github.com/open-telemetry/opentelemetry-ruby-contrib/blob/main/instrumentation/action_pack/example/trace_demonstration.ru)

## How can I get involved?

The `opentelemetry-instrumentation-action_pack` gem source is [on github][repo-github], along with related gems including `opentelemetry-api` and `opentelemetry-sdk`.

The OpenTelemetry Ruby gems are maintained by the OpenTelemetry Ruby special interest group (SIG). You can get involved by joining us on our [GitHub Discussions][discussions-url], [Slack Channel][slack-channel] or attending our weekly meeting. See the [meeting calendar][community-meetings] for dates and times. For more information on this and other language SIGs, see the OpenTelemetry [community page][ruby-sig].

## License

The `opentelemetry-instrumentation-action_pack` gem is distributed under the Apache 2.0 license. See [LICENSE][license-github] for more information.

[bundler-home]: https://bundler.io
[repo-github]: https://github.com/open-telemetry/opentelemetry-ruby
[license-github]: https://github.com/open-telemetry/opentelemetry-ruby-contrib/blob/main/LICENSE
[ruby-sig]: https://github.com/open-telemetry/community#ruby-sig
[community-meetings]: https://github.com/open-telemetry/community#community-meetings
[slack-channel]: https://cloud-native.slack.com/archives/C01NWKKMKMY
[discussions-url]: https://github.com/open-telemetry/opentelemetry-ruby/discussions
[rails-home]: https://rubyonrails.org/

## HTTP semantic convention stability

In the OpenTelemetry ecosystem, HTTP semantic conventions have now reached a stable state. However, the initial Rack instrumentation, which Action Pack relies on, was introduced before this stability was achieved, which resulted in HTTP attributes being based on an older version of the semantic conventions.

To facilitate the migration to stable semantic conventions, you can use the `OTEL_SEMCONV_STABILITY_OPT_IN` environment variable. This variable allows you to opt-in to the new stable conventions, ensuring compatibility and future-proofing your instrumentation.

Sinatra instrumentation installs Rack middleware, but the middleware version it installs depends on which `OTEL_SEMCONV_STABILITY_OPT_IN` environment variable is set.

When setting the value for `OTEL_SEMCONV_STABILITY_OPT_IN`, you can specify which conventions you wish to adopt:

- `http` - Emits the stable HTTP and networking conventions and ceases emitting the old conventions previously emitted by the instrumentation.
- `http/dup` - Emits both the old and stable HTTP and networking conventions, enabling a phased rollout of the stable semantic conventions.
- Default behavior (in the absence of either value) is to continue emitting the old HTTP and networking conventions the instrumentation previously emitted.

During the transition from old to stable conventions, Rack instrumentation code comes in three patch versions: `dup`, `old`, and `stable`. These versions are identical except for the attributes they send. Any changes to Rack instrumentation should consider all three patches.

For additional information on migration, please refer to our [documentation](https://opentelemetry.io/docs/specs/semconv/non-normative/http-migration/).
