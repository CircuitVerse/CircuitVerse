# New Relic Ruby Agent Release Notes #

  ## v8.8.0

  * **Support Makara database adapters with ActiveRecord**

    Thanks to a community submission from @lucasklaassen with [PR #1177](https://github.com/newrelic/newrelic-ruby-agent/pull/1177), the Ruby agent will now correctly work well with the [Makara gem](https://github.com/instacart/makara). Functionality such as SQL obfuscation should now work when Makara database adapters are used with Active Record.

  * **Lowered the minimum payload size to compress**

    Previously the Ruby agent used a particularly large payload size threshold of 64KiB that would need to be met before the agent would compress data en route to New Relic's collector. The original value stems from segfault issues that very old Rubies (< 2.2) used to encounter when compressing smaller payloads. This value has been lowered to 2KiB (2048 bytes), which should provide a more optimal balance between the CPU cycles spent on compression and the bandwidth savings gained from it.

  * **Provide Code Level Metrics for New Relic CodeStream**

    For Ruby on Rails applications and/or those with manually traced methods, the agent is now capable of reporting metrics with Ruby method-level granularity. When the new `code_level_metrics.enabled` configuration parameter is set to a `true` value, the agent will associate source-code-related metadata with the metrics for things such as Rails controller methods. Then, when the corresponding Ruby class file that defines the methods is loaded up in a [New Relic CodeStream](https://www.codestream.com/)-powered IDE, [the four golden signals](https://sre.google/sre-book/monitoring-distributed-systems/) for each method will be presented to the developer directly.

  * **Supportability Metrics will always report uncompressed payload size**

    New Relic's agent specifications call for Supportability Metrics to always reference the uncompressed payload byte size. Previously, the Ruby agent was calculating the byte size after compression. Furthermore, compression is only performed on payloads of a certain size. This means that sometimes the value could have represented a compressed size and sometimes an uncompressed one. Now the uncompressed value is always used, bringing consistency for comparing two instances of the same metric and alignment with the New Relic agent specifications.


  ## v8.7.0

  * **APM logs-in-context log forwarding on by default**

    Automatic application log forwarding is now enabled by default. This version of the agent will automatically send enriched application logs to New Relic. To learn more about about this feature see [here](https://docs.newrelic.com/docs/apm/new-relic-apm/getting-started/get-started-logs-context/), and additional configuration options are available [here](https://docs.newrelic.com/docs/logs/logs-context/configure-logs-context-ruby). To learn about how to toggle log ingestion on or off by account see [here](https://docs.newrelic.com/docs/logs/logs-context/disable-automatic-logging).

  * **Improved async support and Thread instrumentation**

    Previously, the agent was not able to record events and metrics inside Threads created inside of an already running transaction. This release includes 2 new configuration options to support multithreaded applications to automatically instrument threads. A new configuration option,`instrumentation.thread.tracing` (disabled by default), has been introduced that, when enabled, will allow the agent to insert New Relic tracing inside of all Threads created by an application. To support applications that only want some threads instrumented by New Relic, a new class is available, `NewRelic::TracedThread`, that will create a thread that includes New Relic instrumentation, see our [API documentation](https://www.rubydoc.info/gems/newrelic_rpm/NewRelic) for more details.

    New configuration options included in this release:
    | Configuration name | Default | Behavior |
    | ----------- | ----------- |----------- |
    | `instrumentation.thread`  | `auto` (enabled) | Allows the agent to correctly nest spans inside of an asyncronous transaction   |
    | `instrumentation.thread.tracing` | `false` (disabled)   |  Automatically add tracing to all Threads created in the application. This may be enabled by default in a future release. |

    We'd like to thank @mikeantonelli for sharing a gist with us that provided our team with an entry point for this feature.

  * **Deprecate support for Ruby 2.2**

    Ruby 2.2 reached end of life on March 31, 2018. The agent has deprecated support for Ruby 2.2 and will make breaking changes for this version in its next major release.

  *  **Deprecate instrumentation versions with low adoption and/or versions over five years old**

    This release deprecates the following instrumentation:
    | Deprecated | Replacement |
    | ----------- | ----------- |
    | ActiveMerchant < 1.65.0 | ActiveMerchant >= 1.65.0 |
    | Acts As Solr (all versions) | none |
    | Authlogic (all versions) | none |
    | Bunny < 2.7.0 | bunny >= 2.7.0 |
    | Dalli < 3.2.1 | Dalli >= 3.2.1 |
    | DataMapper (all versions) | none |
    | Delayed Job < 4.1.0 | Delayed Job >= 4.1.0 |
    | Excon < 0.56.0 | Excon >= 0.56.0 |
    | Grape < 0.19.2 | Grape >= 0.19.2 |
    | HTTPClient < 2.8.3 | HTTPClient 2.8.3 |
    | HTTP.rb < 2.2.2 | HTTP.rb >= 2.2.2 |
    | Mongo < 2.4.1 | Mongo >= 2.4.1 |
    | Padrino < 0.15.0 | Padrino >= 0.15.0 |
    | Passenger < 5.1.3 | Passenger >= 5.1.3 |
    | Puma < 3.9.0 | Puma >= 3.9.0 |
    | Rack < 1.6.8 | Rack >= 1.6.8 |
    | Rails 3.2.x | Rails >= 4.x |
    | Rainbows (all versions) | none |
    | Sequel < 4.45.0 | Sequel >= 4.45.0 |
    | Sidekiq < 5.0.0 | Sidekiq >= 5.0.0 |
    | Sinatra < 2.0.0 | Sinatra >= 2.0.0 |
    | Sunspot (all versions) | none |
    | Typhoeus < 1.3.0 | Typhoeus >= 1.3.0 |
    | Unicorn < 5.3.0 | Unicorn >= 5.3.0 |

    For the gems with deprecated versions, we will no longer test those versions in our multiverse suite. They may, however, still be compatible with the agent. We will no longer fix bug reports for issues related to these gem versions.

  * **Clarify documentation for `rake.tasks` configuration**

    The `rake.tasks` description in the default `newrelic.yml` file and the [New Relic Ruby Agent Configuration docs](https://docs.newrelic.com/docs/apm/agents/ruby-agent/configuration/ruby-agent-configuration#rake-tasks) have been updated to clarify its behavior and usage. The documentation now reads:

    > Specify an array of Rake tasks to automatically instrument. This configuration option converts the Array to a RegEx list. If you'd like to allow all tasks by default, use `rake.tasks: [.+]`. Rake tasks will not be instrumented unless they're added to this list. For more information, visit the (New Relic Rake Instrumentation docs)[/docs/apm/agents/ruby-agent/background-jobs/rake-instrumentation].

    We thank @robotfelix for suggesting these changes.

  * **Internally leverage `Object.const_get` and `Object.const_defined?`**

    When dynamically checking for or obtaining a handle to a class constant from a string, leverage the `Object` class's built in methods wherever possible to enjoy simpler, more performant operations. All JRubies and CRubies v2.5 and below need a bit of assistance beyond what `Object` can provide given that those Rubies may yield an unwanted constant from a different namespace than the one that was specified. But for all other Rubies and even for those Rubies in contexts where we can 100% trust the string value coming in, leverage the `Object` class's methods and reap the benefits.

  * **Enable Environment Variables setting Array configurations to be converted to Arrays**

    Prior to this change, when comma-separated lists were passed as environment variables, an error would be emitted to the `newrelic_agent.log` and a String would be set as the value. Now, Arrays will be accurately coerced.

  * **Bugfix: Allow TransactionEvents to be sampled at the expected rate**

    The `transaction_events.max_samples_stored` capacity value within the TransactionEventAggregator did not match up with its expected harvest cycle interval, causing TransactionEvents to be over-sampled. This bugfix builds upon the updates made in [#952](https://github.com/newrelic/newrelic-ruby-agent/pull/952) so that the interval and capacity behave as expected for the renamed `transaction_events*` configuration options.

  * **Bugfix: Error events missing attributes when created outside of a transaction**

    Previously the agent was not assigning a priority to error events that were created by calling notice_error outside the scope of a transaction. This caused issues with sampling when the error event buffer was full, resulting in a `NoMethodError: undefined method '<' for nil:NilClass` in the newrelic_agent.log. This bugfix ensures that a priority is always assigned on error events so that the agent will be able to sample these error events correctly. Thank you to @olleolleolle for bringing this issue to our attention.
    


  ## v8.6.0

  * **Telemetry-in-Context: Automatic Application Logs, a quick way to view logs no matter where you are in the platform**

    - Adds support for forwarding application logs to New Relic. This automatically sends application logs that have been enriched to power Telemetry-in-Context. This is disabled by default in this release. This may be on by default in a future release.
    - Adds support for enriching application logs written to disk or standard out. This can be used with another log forwarder to power Telemetry-in-Context if in-agent log forwarding is not desired. We recommend enabling either log forwarding or local log decorating, but not both features. This is disabled by default in this release.
    - Improves speed and Resque support for logging metrics which shows the rate of log message by severity in the Logs chart in the APM Summary view. This is enabled by default in this release.

    To learn more about Telemetry-in-Context and the configuration options please see the documentation [here](https://docs.newrelic.com/docs/apm/agents/ruby-agent/configuration/ruby-agent-configuration/).

  * **Improve the usage of the 'hostname' executable and other executables**

    In all places where a call to an executable binary is made (currently this is done only for the 'hostname' and 'uname' binaries), leverage a new helper method when making the call. This new helper will a) not attempt to execute the binary if it cannot be found, and b) prevent STDERR/STDOUT content from appearing anywhere except New Relic's own logs if the New Relic logger is set to the 'debug' level. When calling 'hostname', fall back to `Socket.gethostname` if the 'hostname' binary cannot be found. When calling 'uname', fall back on using a value of 'unknown' if the 'uname' command fails. Many thanks to @metaskills and @brcarp for letting us know that Ruby AWS Lambda functions can't invoke 'hostname' and for providing ideas and feedback with [Issue #697](https://github.com/newrelic/newrelic-ruby-agent/issues/697).

  * **Documentation: remove confusing duplicate RUM entry from newrelic.yml**

    The `browser_monitoring.auto_instrument` configuration option to enable web page load timing (RUM) was confusingly listed twice in the newrelic.yml config file. This option is enabled by default. The newrelic.yml file has been updated to list the option only once. Many thanks to @robotfelix for bringing this to our attention with [Issue #955](https://github.com/newrelic/newrelic-ruby-agent/issues/955).

  * **Bugfix: fix unit test failures when New Relic environment variables are present**

    Previously, unit tests would fail with unexpected invocation errors when `NEW_RELIC_LICENSE_KEY` and `NEW_RELIC_HOST` environment variables were present. Now, tests will discard these environment variables before running.

  * **Bugfix: Curb - satify method_with_tracing's verb argument requirement**

    When Curb instrumentation is used (either via prepend or chain), be sure to always pass the verb argument over to `method_with_tracing` which requires it. Thank you to @knarewski for bringing this issue to our attention, for providing a means of reproducing an error, and for providing a fix. That fix has been replicated by the agent team with permission. See [Issue 1033](https://github.com/newrelic/newrelic-ruby-agent/issues/1033) for more details.


  ## v8.5.0

  * **AWS: Support IMDSv2 by using a token with metadata API calls**

    When querying AWS for instance metadata, include a token in the request headers. If an AWS user configures instances to require a token, the agent will now work. For instances that do not require the inclusion of a token, the agent will continue to work in that context as well.

  * **Muffle anticipated stderr warnings for "hostname" calls**

    When using the `hostname` binary to obtain hostname information, redirect STDERR to /dev/null. Thanks very much to @frenkel for raising this issue on behalf of OpenBSD users everywhere and for providing a solution with [PR #965](https://github.com/newrelic/newrelic-ruby-agent/pull/965).

  * **Added updated configuration options for transaction events and deprecated previous configs**
    This release deprecates and replaces the following configuration options:
    | Deprecated      | Replacement |
    | ----------- | ----------- |
    | event_report_period.analytic_event_data | event_report_period.transaction_event_data |
    | analytics_events.enabled | transaction_events.enabled        |
    | analytics_events.max_samples_stored | transaction_events.max_samples_stored |

  * **Eliminated warnings for redefined constants in ParameterFiltering**

    Fixed the ParameterFiltering constant definitions so that they are not redefined on multiple reloads of the module. Thank you to @TonyArra for bringing this issue to our attention.

  * **Docker for development**

    Docker and Docker Compose may now be used for local development and testing with the provided `Dockerfile` and `docker-compose.yml` files in the project root. See [DOCKER.md](DOCKER.md) for usage instructions.


  * **Bugfix: Rails 5 + Puma errors in rack "can't add a new key into hash during iteration"**

    When using rails 5 with puma, the agent would intermittently cause rack to raise a `RuntimeError: can't add a new key into hash during iteration`. We have identified the source of the error in our instrumentation and corrected the behavior so it no longer interferes with rack. Thanks to @sasharevzin for bringing attention to this error and providing a reproduction of the issue for us to investigate.

  * **CI: target JRuby 9.3.3.0**

    Many thanks to @ahorek for [PR #919](https://github.com/newrelic/newrelic-ruby-agent/pull/919), [PR #921](https://github.com/newrelic/newrelic-ruby-agent/pull/921), and [PR #922](https://github.com/newrelic/newrelic-ruby-agent/pull/922) to keep us up to date on the JRuby side of things. The agent is now actively being tested against JRuby 9.3.3.0. NOTE that this release does not contain any non-CI related changes for JRuby. Old agent versions are still expected to work with newer JRubies and the newest agent version is still expected to work with older JRubies.

  * **CI: Update unit tests for Rails 7.0.2**

    Ensure that the 7.0.2 release of Rails is fully compatible with all relevant tests.

  * **CI: Ubuntu 20.04 LTS**

    To stay current and secure, our CI automation is now backed by version 20.04 of Ubuntu's long term support offering (previously 18.04).


  ## v8.4.0

  * **Provide basic support for Rails 7.0**

  This release includes Rails 7.0 as a tested Rails version. Updates build upon the agent's current Rails instrumentation and do not include additional instrumentation for new features.

  * **Improve the performance of NewRelic::Agent::GuidGenerator#generate_guid**

  This method is called by many basic operations within the agent including transactions, datastore segments, and external request segments. Thank you, @jdelstrother for contributing this performance improvement!

  * **Documentation: Development environment prep instructions**

  The multiverse collection of test suites requires a variety of data handling software (MySQL, Redis, memcached, etc.) to be available on the machine running the tests. The [project documentation](test/multiverse/README.md) has been updated to outline the relevant software packages, and a `Brewfile` file has been added to automate software installation with Homebrew.

  * **Bugfix: Add ControllerInstrumentation::Shims to Sinatra framework**

    When the agent is disabled by setting the configuration settings `enabled`, `agent_enabled`, and/or `monitor_mode` to false, the agent loads shims for public controller instrumentation methods. These shims were missing for the Sinatra framework, causing applications to crash if the agent was disabled. Thank you, @NC-piercej for bringing this to our attention!


  ## v8.3.0

  * **Updated the agent to support Ruby 3.1.0**

    Most of the changes involved updating the multiverse suite to exclude runs for older versions of instrumented gems that are not compatible with Ruby 3.1.0. In addition, Infinite Tracing testing was updated to accommodate `YAML::unsafe_load` for Psych 4 support.

  * **Bugfix: Update AdaptiveSampler#sampled? algorithm**

    One of the clauses in `AdaptiveSampler#sampled?` would always return false due to Integer division returning a result of zero. This method has been updated to use Float division instead, to exponentially back off the number of samples required. This may increase the number of traces collected for transactions. A huge thank you to @romul for bringing this to our attention and breaking down the problem!

  * **Bugfix: Correctly encode ASCII-8BIT log messages**

    The encoding update for the DecoratingLogger in v8.2.0 did not account for ASCII-8BIT encoded characters qualifying as `valid_encoding?`. Now, ASCII-8BIT characters will be encoded as UTF-8 and include replacement characters as needed. We're very grateful for @nikajukic's collaboration and submission of a test case to resolve this issue.


  ## v8.2.0

  * **New Instrumentation for Tilt gem**

    Template rendering using [Tilt](https://github.com/rtomayko/tilt) is now instrumented. See [PR #847](https://github.com/newrelic/newrelic-ruby-agent/pull/847) for details.

  * **Configuration `error_collector.ignore_errors` is marked as deprecated**

    This setting has been marked as deprecated in the documentation since version 7.2.0 and is now flagged as deprecated within the code.

  * **Remove Rails 2 instrumentation**

    Though any version of Rails 2 has not been supported by the Ruby Agent since v3.18.1.330, instrumentation for ActionController and ActionWebService specific to that version were still part of the agent. This instrumentation has been removed.

  * **Remove duplicated settings from newrelic.yml**

    Thank you @jakeonfire for bringing this to our attention and @kuroponzu for making the changes!

  * **Bugfix: Span Events recorded when using newrelic_ignore**

    Previously, the agent was incorrectly recording span events only on transactions that should be ignored. This fix will prevent any span events from being created for transactions using newrelic_ignore, or ignored through the `rules.ignore_url_regexes` configuration option.

  * **Bugfix: Print deprecation warning for Cross-Application Tracing if enabled**

    Prior to this change, the deprecation warning would log whenever the agent started up, regardless of configuration. Thank you @alpha-san for bringing this to our attention!

  * **Bugfix: Scrub non-unicode characters from DecoratingLogger**

    To prevent `JSON::GeneratorErrors`, the DecoratingLogger replaces non-unicode characters with the replacement character: �. Thank you @jdelStrother for bringing this to our attention!

  * **Bugfix: Distributed tracing headers emitted errors when agent was not connected**

    Previously, when the agent had not yet connected it would fail to create a trace context payload and emit an error, "TypeError: no implicit conversion of nil into String," to the agent logs. The correct behavior in this situation is to not create these headers due to the lack of required information. Now, the agent will not attempt to create trace context payloads until it has connected. Thank you @Izzette for bringing this to our attention!


  ## v8.1.0

  * **Instrumentation for Ruby standard library Logger**

    The agent will now automatically instrument Logger, recording number of lines and size of logging output, with breakdown by severity.

  * **Bugfix for Padrino instrumentation**

    A bug was introduced to the way the agent installs padrino instrumentation in 7.0.0. This release fixes the issues with the padrino instrumentation. Thanks to @sriedel for bringing this issue to our attention.

  * **Bugfix: Stop deadlocks between New Relic thread and Delayed Job sampling thread**

    Running the agent's polling queries for the DelayedJobSampler within the same ActiveRecord connection decreases the frequency of deadlocks in development environments. Thanks @jdelStrother for bringing this to our attention and providing excellent sample code to speed up development!

  * **Bugfix: Allow Net::HTTP request to IPv6 addresses**

    The agent will no longer raise an `URI::InvalidURIError` error if an IPv6 address is passed to Net::HTTP. Thank you @tristinbarnett and @tabathadelane for crafting a solution!

  * **Bugfix: Allow integers to be passed to error_collector.ignore_status_codes configuration**

    Integers not wrapped in quotation marks can be passed to `error_collector.ignore_status_codes` in the `newrelic.yml` file. Our thanks goes to @elaguerta and @brammerl for resolving this issue!

  * **Bugfix: Allow add_method_tracer to be used on BasicObjects**

    Previously, our `add_method_tracer` changes referenced `self.class` which is not available on `BasicObjects`. This has been fixed. Thanks to @toncid for bringing this issue to our attention.


  ## v8.0.0

  * **`add_method_tracer` refactored to use prepend over alias_method chaining**

    This release overhauls the implementation of `add_method_tracer`, as detailed in [issue #502](https://github.com/newrelic/newrelic-ruby-agent/issues/502). The main breaking updates are as follows:
    - A metric name passed to `add_method_tracer` will no longer be interpolated in an instance context as before. To maintain this behavior, pass a Proc object with the same arity as the method being traced. For example:
      ```ruby
        # OLD
        add_method_tracer :foo, '#{args[0]}.#{args[1]}'

        # NEW
        add_method_tracer :foo, -> (*args) { "#{args[0]}.#{args[1]}" }
      ```

    - Similarly, the `:code_header` and `:code_footer` options to `add_method_tracer` will *only* accept a Proc object, which will be bound to the calling instance when the traced method is invoked.

    - Calling `add_method_tracer` for a method will overwrite any previously defined tracers for that method. To specify multiple metric names for a single method tracer, pass them to `add_method_tracer` as an array.

    See updated documentation on the following pages for full details:
    - [Ruby Custom Instrumentation: Method Tracers](https://docs.newrelic.com/docs/agents/ruby-agent/api-guides/ruby-custom-instrumentation/#method_tracers)
    - [MethodTracer::ClassMethods#add_method_tracer](https://rubydoc.info/github/newrelic/newrelic-ruby-agent/NewRelic/Agent/MethodTracer/ClassMethods#add_method_tracer-instance_method)


  * **Distributed tracing is enabled by default**

    [Distributed tracing](https://docs.newrelic.com/docs/distributed-tracing/enable-configure/language-agents-enable-distributed-tracing/) tracks and observes service requests as they flow through distributed systems. Distributed tracing is now enabled by default and replaces [cross application tracing](https://docs.newrelic.com/docs/agents/ruby-agent/features/cross-application-tracing-ruby/).

  * **Bugfix: Incorrectly loading configuration options from newrelic.yml**

    The agent will now  import the configuration options [`error_collector.ignore_messages`](https://docs.newrelic.com/docs/agents/ruby-agent/configuration/ruby-agent-configuration/#error_collector-ignore_messages) and [`error_collector.expected_messages`](https://docs.newrelic.com/docs/agents/ruby-agent/configuration/ruby-agent-configuration/#error_collector-expected_messages) from the `newrelic.yml` file correctly.

  * **Cross Application is now deprecated, and disabled by default**

    [Distributed tracing](https://docs.newrelic.com/docs/distributed-tracing/enable-configure/language-agents-enable-distributed-tracing/) is replacing [cross application tracing](https://docs.newrelic.com/docs/agents/ruby-agent/features/cross-application-tracing-ruby/) as the default means of tracing between services. To continue using it, enable it with `cross_application_tracer.enabled: true` and `distributed_tracing.enabled: false`

  * **Update configuration option default value for `span_events.max_samples_stored` from 1000 to 2000**

    For more information about this congfiguration option, visit [the Ruby agent documentation](https://docs.newrelic.com/docs/agents/ruby-agent/configuration/ruby-agent-configuration/#span_events-max_samples_stored).

  * **Agent now enforces server supplied maximum value for configuration option `span_events.max_samples_stored`**

    Upon connection to the New Relic servers, the agent will now enforce a maximum value allowed for the configuration option [`span_events.max_samples_stored`](https://docs.newrelic.com/docs/agents/ruby-agent/configuration/ruby-agent-configuration/#span_events-max_samples_stored) sent from the New Relic servers.

  * **Remove Ruby 2.0 required kwarg compatibility checks**

    Our agent has code that provides compatibility for required keyword arguments in Ruby versions below 2.1. Since the agent now only supports Ruby 2.2+, this code is no longer required.

  * **Replace Time.now with Process.clock_gettime**

    Calls to `Time.now` have been replaced with calls to `Process.clock_gettime` to leverage the system's built-in clocks for elapsed time (`Process::CLOCK_MONOTONIC`) and wall-clock time (`Process::CLOCK_REALTIME`). This results in fewer object allocations, more accurate elapsed time records, and enhanced performance. Thanks to @sdemjanenko and @viraptor for advocating for this change!

  * **Updated generated default newrelic.yml**

    Thank you @wyhaines and @creaturenex for your contribution. The default newrelic.yml that the agent can generate is now updated with commented out examples of all configuration options.

  * **Bugfix: Psych 4.0 causes errors when loading newrelic.yml**

    Psych 4.0 now uses safe load behavior when using `YAML.load` which by default doesn't allow aliases, causing errors when the agent loads the config file. We have updated how we load the config file to avoid these errors.

  * **Remove support for Excon versions below 0.19.0**

    Excon versions below 0.19.0 will no longer be instrumented through the Ruby agent.

  * **Remove support for Mongo versions below 2.1**

    Mongo versions below 2.1 will no longer be instrumented through the Ruby agent.

  * **Remove tests for Rails 3.0 and Rails 3.1**

    As of the 7.0 release, the Ruby agent stopped supporting Rails 3.0 and Rails 3.1. Despite this, we still had tests for these versions running on the agent's CI. Those tests are now removed.

  * **Update test Gemfiles for patched versions**

    The gem has individual Gemfiles it uses to test against different common user setups. Rails 5.2, 6.0, and 6.1 have been updated to the latest patch versions in the test Gemfiles. Rack was updated in the Rails61 test suite to 2.1.4 to resolve a security vulnerability.

  * **Remove Merb Support**

    This release removes the remaining support for the [Merb](https://weblog.rubyonrails.org/2008/12/23/merb-gets-merged-into-rails-3/) framework. It merged with Rails during the 3.0 release. Now that the Ruby agent supports Rails 3.2 and above, we thought it was time to say goodbye.

  * **Remove deprecated method External.start_segment**

    The method `NewRelic::Agent::External.start_segment` has been deprecated as of Ruby Agent 6.0.0. This method is now removed.

  * **Added testing and support for the following gem versions**

    - activemerchant 1.121.0
    - bunny 2.19.0
    - excon 0.85.0
    - mongo 2.14.0, 2.15.1
    - padrino 0.15.1
    - resque 2.1.0
    - sequel 5.48.0
    - yajl-ruby 1.4.1

  * **This version adds support for ARM64/Graviton2 platform using Ruby 3.0.2+**


  ## v7.2.0

  * **Expected Errors and Ignore Errors**
    This release adds support for configuration for expected/ignored errors by class name, status code, and message. The following configuration options are now available:
    - `error_collector.ignore_classes`
    - `error_collector.ignore_messages`
    - `error_collector.ignore_status_codes`
    - `error_collector.expected_classes`
    - `error_collector.expected_messages`
    - `error_collector.expected_status_codes`
    For more details about expected and ignored errors, please see our [configuration documentation](https://docs.newrelic.com/docs/agents/ruby-agent/configuration/)

  * **Bugfix: resolves "can't add a new key into hash during iteration" Errors**

    Thanks to @wyhaines for this fix that prevents "can't add a new key into hash during iteration" errors from occuring when iterating over environment data.

  * **Bugfix: kwarg support fixed for Rack middleware instrumentation**

    Thanks to @walro for submitting this fix. This fixes the rack instrumentation when using kwargs.

  * **Update known conflicts with use of Module#Prepend**

    With our release of v7.0.0, we updated our instrumentation to use Module#Prepend by default, instead of method chaining. We have received reports of conflicts and added a check for these known conflicts. If a known conflict with prepend is detected while using the default value of 'auto' for gem instrumentation, the agent will instead install method chaining instrumentation in order to avoid this conflict. This check can be bypassed by setting the instrumentation method for the gem to 'prepend'.

  ## v7.1.0

  * **Add support for CSP nonces when using our API to insert the browser agent**

    We now support passing in a nonce to our API method `browser_timing_header` to allow the browser agent to run on applications using CSP nonces. This allows users to inject the browser agent themselves and use the nonce required for the script to run. In order to utilize this new feature, you must disable auto instrumentation for the browser agent, and use the API method browser_timing_header to pass the nonce in and inject the script manually.

  * **Removed MD5 use in the SQL sampler**

    In order to allow the agent to run in FIPS compliant environments, the usage of MD5 for aggregating slow sql traces has been replaced with SHA1.

  * **Enable server-side configuration of distributed tracing**

    `distributed_tracing.enabled` may now be set in server-side application configuration.

  * **Bugfix: Fix for missing part of a previous bugfix**

    Our previous fix of "nil Middlewares injection now prevented and gracefully handled in Sinatra" released in 7.0.0 was partially overwritten by some of the other changes in that release. This release adds back those missing sections of the bugfix, and should resolve the issue for sinatra users.

  * **Update known conflicts with use of Module#Prepend**

    With our release of v7.0.0, we updated our instrumentation to use Module#Prepend by default, instead of method chaining. We have received reports of conflicts and added a check for these known conflicts. If a known conflict with prepend is detected while using the default value of 'auto' for gem instrumentation, the agent will instead install method chaining instrumentation in order to avoid this conflict. This check can be bypassed by setting the instrumentation method for the gem to 'prepend'.

  * **Bugfix: Updated support for ActiveRecord 6.1+ instrumentation**

    Previously, the agent depended on `connection_id` to be present in the Active Support instrumentation for `sql.active_record`
    to get the current ActiveRecord connection. As of Rails 6.1, `connection_id` has been dropped in favor of providing the connection
    object through the `connection` value exclusively. This resulted in datastore spans displaying fallback behavior, including showing
    "ActiveRecord" as the database vendor.

  * **Bugfix: Updated support for Resque's FORK_PER_JOB option**

    Support for Resque's FORK_PER_JOB flag within the Ruby agent was incomplete and nonfunctional. The agent should now behave
    correctly when running in a non-forking Resque worker process.

  * **Bugfix: Added check for ruby2_keywords in add_transaction_tracer**

    Thanks @beauraF for the contribution! Previously, the add_transaction_tracer was not updated when we added support for ruby 3. In order to correctly support `**kwargs`,  ruby2_keywords was added to correctly update the method signature to use **kwargs in ruby versions that support that.

  * **Confirmed support for yajl 1.4.0**

    Thanks to @creaturenex for the contribution! `yajl-ruby` 1.4.0 was added to our test suite and confirmed all tests pass, showing the agent supports this version as well.


  ## v7.0.0

  * **Ruby Agent 6.x to 7.x Migration Guide Available**

    Please see our [Ruby Agent 6.x to 7.x migration guide](https://docs.newrelic.com/docs/agents/ruby-agent/getting-started/migration-7x-guide/) for helpful strategies and tips for migrating from earlier versions of the Ruby agent to 7.0.0.  We cover new configuration settings, diagnosiing and installing SSL CA certificates and deprecated items and their replacements in this guide.

  * **Ruby 2.0 and 2.1 Dropped**

    Support for Ruby 2.0 and 2.1 dropped with this release.  No code changes that would prevent the agent from continuing to
    work with these releases are known.  However, Rubies 2.0 and 2.1 are no longer included in our test matrices and are not supported
    for 7.0.0 and onward.

  * **Implemented prepend auto-instrumentation strategies for most Ruby gems/libraries**

    This release brings the auto-instrumentation strategies for most gems into the modern era for Ruby by providing both
    prepend and method-chaining (a.k.a. method-aliasing) strategies for auto instrumenting.  Prepend, which has been available since
    Ruby 2.0 is now the default strategy employed in auto-instrumenting.  It is known that some external gems lead to Stack Level
    too Deep exceptions when prepend and method-chaining are mixed.  In such known cases, auto-instrumenting strategy will fall back
    to method-chaining automatically.

    This release also deprecates many overlapping and inconsistently named configuration settings in favor of being able to control
    behavior of instrumentation per library with one setting that can be one of auto (the default), disabled, prepend, or chain.

    Please see the above-referenced migration guide for further details.

  * **Removed SSL cert bundle**

    The agent will no longer ship this bundle and will rely on system certs.

  * **Removed deprecated config options**

    The following config options were previously deprecated and are no longer available
    - `disable_active_record_4`
    - `disable_active_record_5`
    - `autostart.blacklisted_constants`
    - `autostart.blacklisted_executables`
    - `autostart.blacklisted_rake_tasks`
    - `strip_exception_messages.whitelist`

  * **Removed deprecated attribute**

    The attribute `httpResponseCode` was previously deprecated and replaced with `http.statusCode`. This deprecated attribute has now been removed.

  * **Removed deprecated option in notice_error**

    Previously, the `:trace_only` option to NewRelic::Agent.notice_error was deprecated and replaced with `:expected`. This deprecated option has been removed.

  * **Removed deprecated api methods**

    Previously the api methods `create_distributed_trace_payload` and `accept_distributed_trace_payload` were deprecated. These have now been removed. Instead, please see `insert_distributed_trace_headers` and `accept_distributed_trace_headers`, respectively.

  * **Bugfix: Prevent browser monitoring middleware from installing to middleware multiple times**

    In rare cases on jRuby, the BrowserMonitoring middleware could attempt to install itself
    multiple times at start up.  This bug fix addresses that by using a mutex to introduce
    thread safety to the operation.  Sintra in particular can have this race condition because
    its middleware stack is not installed until the first request is received.

  * **Skip constructing Time for transactions**

    Thanks to @viraptor, we are no longer constructing an unused Time object with every call to starting a new Transaction.

  * **Bugfix: nil Middlewares injection now prevented and gracefully handled in Sinatra**

    Previously, the agent could potentially inject multiples of an instrumented middleware if Sinatra received many
    requests at once during start up and initialization due to Sinatra's ability to delay full start up as long as possible.
    This has now been fixed and the Ruby agent correctly instruments only once as well as gracefully handles nil middleware
    classes in general.

  * **Bugfix: Ensure transaction nesting max depth is always consistent with length of segments**

    Thanks to @warp for noticing and fixing the scenario where Transaction nesting_max_depth can get out of sync
    with segments length resulting in an exception when attempting to nest the initial segment which does not exist.

  ## v6.15.0

  * **Official Ruby 3.0 support**

    The ruby agent has been verified to run on ruby 3.0.0

  * **Added support for Rails 6.1**

    The ruby agent has been verified to run with Rails 6.1
    Special thanks to @hasghari for setting this up!

  * **Added support for Sidekiq 6.0, 6.1**

    The ruby agent has been verified to run with both 6.0 and 6.1 versions of sidekiq

  * **Bugfix: No longer overwrites sidekiq trace data**

    Distributed tracing data is now added to the job trace info rather than overwriting the existing data.

  * **Bugfix: Fixes cases where errors are reported for spans with no other attributes**

    Previously, in cases where a span does not have any agent/custom attributes on it, but an error
    is noticed and recorded against the span, a `FrozenError: can't modify frozen Hash` is thrown.
    This is now fixed and errors are now correctly recorded against such span events.

  * **Bugfix: `DistributedTracing.insert_distributed_trace_headers` Supportability metric now recorded**

    Previously, API calls to `DistributedTracing.insert_distributed_trace_headers` would lead to an exception
    about the missing supportability metric rather than flowing through the API implementation as intended.
    This would potentially lead to broken distributed traces as the trace headers were not inserted on the API call.
    `DistributedTracing.insert_distributed_trace_headers` now correctly records the supportability metric and
    inserts the distributed trace headers as intended.

  * **Bugfix: child completions after parent completes sometimes throws exception attempting to access nil parent**

    In scenarios where the child segment/span is completing after the parent in jRuby, the parent may have already
    been freed and no longer accessible.  This would lead to an attempt to call `descendant_complete` on a Nil
    object.  This is fixed to protect against calling the `descendant_complete` in such cases.

  * **Feature: implements `force_install_exit_handler` config flag**

    The `force_install_exit_handler` configuration flag allows an application to instruct the agent to install its
    graceful shutdown exit handler, which will send any locally cached data to the New Relic collector prior to the
    application shutting down.  This is useful for when the primary framework has an embedded Sinatra application that
    is otherwise detected and skips installing the exit hook for graceful shutdowns.

  * **Default prepend_net_instrumentation to false**

    Previously, `prepend_net_instrumentation` defaulted to true. However, many gems are still using monkey patching on Net::HTTP, which causes compatibility issues with using prepend. Defaulting this to false minimizes instances of
    unexpected compatibilty issues.

  ## v6.14.0

  * **Bugfix: Method tracers no longer cloning arguments**

    Previously, when calling add_method_tracer with certain combination of arguments, it would lead to the wrapped method's arguments being cloned rather than passed to the original method for manipulation as intended.  This has been fixed.

  * **Bugfix: Delayed Job instrumentation fixed for Ruby 2.7+**

    Previously, the agent was erroneousy separating positional and keyword arguments on the instrumented method calls into
    Delayed Job's library.  The led to Delayed job not auto-instrumenting correctly and has been fixed.

  * **Bugfix: Ruby 2.7+ methods sometimes erroneously attributed compiler warnings to the Agent's `add_method_tracer`**

    The specific edge cases presented are now fixed by this release of the agent.  There are still some known corner-cases
    that will be resolved with upcoming changes in next major release of the Agent.  If you encounter a problem with adding
    method tracers and compiler warnings raised, please continue to submit small repoducible examples.

  * **Bugfix: Ruby 2.7+ fix for keyword arguments on Rack apps is unnecessary and removed**

    A common fix for positional and keyword arguments for method parameters was implemented where it was not needed and
    led to RackApps getting extra arguments converted to keyword arguments rather than Hash when it expected one.  This
    Ruby 2.7+ change was reverted so that Rack apps behave correctly for Ruby >= 2.7.

  * **Feature: captures incoming and outgoing request headers for distributed tracing**

    HTTP request headers will be logged when log level is at least debug level.  Similarly, request headers
    for exchanges with New Relic servers are now audit logged when audit logging is enabled.

  * **Bugfix: `newrelic.yml.erb` added to the configuration search path**

    Previously, when a user specifies a `newrelic.yml.erb` and no `newrelic.yml` file, the agent fails to find
    the `.erb` file because it was not in the list of files searched at startup.  The Ruby agent has long supported this as a
    means of configuring the agent programatically.  The `newrelic.yml.erb` filename is restored to the search
    path and will be utilized if present.  NOTE:  `newrelic.yml` still takes precedence over `newrelic.yml.erb`  If found,
    the `.yml` file is used instead of the `.erb` file.  Search directories and order of traversal remain unchanged.

  * **Bugfix: dependency detection of Redis now works without raising an exception**

    Previously, when detecting if Redis was available to instrument, the dependency detection would fail with an Exception raised
    (with side effect of not attempting to instrument Redis).  This is now fixed with a better dependency check that resolves falsly without raising an `Exception`.

  * **Bugfix: Gracefully handles NilClass as a Middleware Class when instrumenting**

    Previously, if a NilClass is passed as the Middleware Class to instrument when processing the middleware stack,
    the agent would fail to fully load and instrument the middleware stack.  This fix gracefully skips over nil classes.

  * **Memory Sampler updated to recognize macOS Big Sur**

    Previously, the agent was unable to recognize the platform macOS Big Sur in the memory sampler, resulting in an error being logged. The memory sampler is now able to recognize Big Sur.

  * **Prepend implementation of Net::HTTP instrumentation available**

    There is now a config option (`prepend_net_instrumentation`) that will enable the agent to use prepend while instrumenting Net::HTTP. This option is set to true by default.

  ## v6.13.1

  * **Bugfix: obfuscating URLs to external services no longer modifying original URI**

    A recent change to the Ruby agent to obfuscate URIs sent to external services had the unintended side-effect of removing query parameters
    from the original URI.  This is fixed to obfuscate while also preserving the original URI.

    Thanks to @VictorJimenezKwast for pinpointing and helpful unit test to demonstrate.

  ## v6.13.0

  * **Bugfix: never use redirect host when accessing preconnect endpoint**

    When connecting to New Relic, the Ruby Agent uses the value in `Agent.config[:host]` to post a request to the New Relic preconnect endpoint. This endpoint returns a "redirect host" which is the URL to which agents send data from that point on.

    Previously, if the agent needed to reconnect to the collector, it would incorrectly use this redirect host to call the preconnect
    endpoint, when it should have used the original configured value in `Agent.config[:host]`. The agent now uses the correct host
    for all calls to preconnect.

  * **Bugfix: calling `add_custom_attributes` no longer modifies the params of the caller**

    The previous agent's improvements to recording attributes at the span level had an unexpected
    side-effect of modifying the params passed to the API call as duplicated attributes were deleted
    in the process. This is now fixed and params passed in are no longer modified.

    Thanks to Pete Johns (@johnsyweb) for the PR that resolves this bug.

  * **Bugfix: `http.url` query parameters spans are now obfuscated**

    Previously, the agent was recording the full URL of the external requests, including
    the query and fragment parts of the URL as part of the attributes on the external request
    span.  This has been fixed so that the URL is obfuscated to filter out potentially sensitive data.

  * **Use system SSL certificates by default**

    The Ruby agent previously used a root SSL/TLS certificate bundle by default. Now the agent will attempt to use
    the default system certificates, but will fall back to the bundled certs if there is an issue (and log that this occurred).

  * **Bugfix: reduce allocations for segment attributes**

    Previously, every segment received an `Attributes` object on initialization. The agent now lazily creates attributes
    on segments, resulting in a significant reduction in object allocations for a typical transaction.

  * **Bugfix: eliminate errors around Rake::VERSION with Rails**

    When running a Rails application with rake tasks, customers could see the following error:

  * **Prevent connecting agent thread from hanging on shutdown**

    A bug in `Net::HTTP`'s Gzip decoder can cause the (un-catchable)
    thread-kill exception to be replaced with a (catchable) `Zlib` exception,
    which prevents a connecting agent thread from exiting during shutdown,
    causing the Ruby process to hang indefinitely.
    This workaround checks for an `aborting` thread in the `#connect` exception handler
    and re-raises the exception, allowing a killed thread to continue exiting.

    Thanks to Will Jordan (@wjordan) for chasing this one down and patching with tests.

  * **Fix error messages about Rake instrumentation**

    When running a Rails application with rake tasks, customers could see the following error in logs resulting from
    a small part of rake functionality being loaded with the Rails test runner:

    ```
    ERROR : Error while detecting rake_instrumentation:
    ERROR : NameError: uninitialized constant Rake::VERSION
    ```

    Such error messages should no longer appear in this context.

    Thanks to @CamilleDrapier for pointing out this issue.

  * **Remove NewRelic::Metrics**

    The `NewRelic::Metrics` module has been removed from the agent since it is no longer used.

    Thanks to @csaura for the contribution!

  ## v6.12.0

  * The New Relic Ruby Agent is now open source under the [Apache 2 license](LICENSE)
    and you can now observe the [issues we're working on](https://github.com/orgs/newrelic/projects/17). See our [Contributing guide](https://github.com/newrelic/newrelic-ruby-agent/blob/main/CONTRIBUTING.md)
    and [Code of Conduct](https://github.com/newrelic/.github/blob/master/CODE_OF_CONDUCT.md) for details on contributing!

  * **Security: Updated all uses of Rake to >= 12.3.3**

    All versions of Rake testing prior to 12.3.3 were removed to address
    [CVE-2020-8130](https://nvd.nist.gov/vuln/detail/CVE-2020-8130).
    No functionality in the agent was removed nor deprecated with this change, and older versions
    of rake are expected to continue to work as they have in the past.  However, versions of
    rake < 12.3.3 are no longer tested nor supported.

  * **Bugfix: fixes an error capturing content length in middleware on multi-part responses**

    In the middleware tracing, the `Content-Length` header is sometimes returned as an array of
    values when content is a multi-part response.  Previously, the agent would fail with
    "NoMethodError: undefined method `to_i` for Array" Error.  This bug is now fixed and
    multi-part content lengths are summed for a total when an `Array` is present.

  * **Added support for auto-instrumenting Mongo gem versions 2.6 to 2.12**

  * **Bugfix: MongoDB instrumentation did not handle CommandFailed events when noticing errors**

    The mongo gem sometimes returns a CommandFailed object instead of a CommandSucceeded object with
    error attributes populated.  The instrumentation did not handle noticing errors on CommandFailed
    objects and resulted in logging an error and backtrace to the log file.

    Additionally, a bug in recording the metric for "findAndModify" as all lowercased "findandmodify"
    for versions 2.1 through 2.5 was fixed.

  * **Bugfix: Priority Sampler causes crash in high throughput environents in rare cases**

    Previously, the priority sampling buffer would, in rare cases, generate an error in high-throughput
    environments once capacity is reached and the sampling algorthym engages.  This issue is fixed.

  * **Additional Transaction Information applied to Span Events**

    When Distributed Tracing and/or Infinite Tracing are enabled, the Agent will now incorporate additional information from the Transaction Event on to the root Span Event of the transaction.

    The following items are affected:
      * Custom attribute values applied to the Transaction via our [add_custom_attributes](http://www.rubydoc.info/github/newrelic/newrelic-ruby-agent/NewRelic/Agent#add_custom_attributes-instance_method) API method.
      * Request parameters: `request.parameters.*`
      * Request headers: `request.headers.*`
      * Response headers: `response.headers.*`
      * Resque job arguments: `job.resque.args.*`
      * Sidekiq job arguments: `job.sidekiq.args.*`
      * Messaging arguments: `message.*`
      * `httpResponseCode` (deprecated in this version; see note below)/`http.statusCode`
      * `response.status`
      * `request.uri`
      * `request.method`
      * `host.displayName`

  * **Security Recommendation**

    Review your Transaction attributes [include](https://docs.newrelic.com/docs/agents/ruby-agent/attributes/enable-disable-attributes-ruby#transaction_events-attributes-include) and [exclude](https://docs.newrelic.com/docs/agents/ruby-agent/attributes/enable-disable-attributes-ruby#transaction_events-attributes-exclude) configurations.  Any attribute include or exclude settings specific to Transaction Events should be applied
    to your Span attributes [include](https://docs.newrelic.com/docs/agents/ruby-agent/attributes/enable-disable-attributes-ruby#span-events-attributes-include) and [exclude](https://docs.newrelic.com/docs/agents/ruby-agent/attributes/enable-disable-attributes-ruby#span-events-attributes-exclude) configuration or your global attributes [include](https://docs.newrelic.com/docs/agents/ruby-agent/attributes/enable-disable-attributes-ruby#attributes-include) and [exclude](https://docs.newrelic.com/docs/agents/ruby-agent/attributes/enable-disable-attributes-ruby#attributes-exclude) configuration.

  * **Agent attribute deprecation: httpResponseCode**

    Starting in this agent version, the [agent attribute](https://docs.newrelic.com/docs/agents/ruby-agent/attributes/ruby-agent-attributes#attributes) `httpResponseCode` (string value) has been deprecated. Customers can begin using `http.statusCode`
    (integer value) immediately, and `httpResponseCode` will be removed in the agent's next major version update.

  * **Bugfix: Eliminate warnings for distributed tracing when using sidekiq**

    Previously, using sidekiq with distributed tracing disabled resulted in warning messages\
    `WARN : Not configured to accept distributed trace headers`\
    ` WARN : Not configured to insert distributed trace headers`\
    These messages no longer appear.

  ## v6.11.0

  * **Infinite Tracing**

    This release adds support for [Infinite Tracing](https://docs.newrelic.com/docs/understand-dependencies/distributed-tracing/enable-configure/enable-distributed-tracing). Infinite Tracing observes 100% of your distributed traces and provides visualizations for the most actionable data. With Infinite Tracing, you get examples of errors and long-running traces so you can better diagnose and troubleshoot your systems.

    Configure your agent to send traces to a trace observer in New Relic Edge. View distributed traces through New Relic’s UI. There is no need to install a collector on your network.

    Infinite Tracing is currently available on a sign-up basis. If you would like to participate, please contact your sales representative.

  * **Bugfix: Cross Application Tracing (CAT) adds a missing field to response**

    Previously, the Ruby agent's Cross Application Tracing header was missing a reserved field that would lead to an error
    in the Go agent's processing of incoming headers from the Ruby agent. This fix adds that missing field to the headers, eliminating
    the issue with traces involving the Ruby agent and the Go agent.

  * **Bugfix: Environment Report now supports Rails >= 6.1**

    Previously, users of Rails 6.1 would see the following deprecation warning appear when the Ruby agent attempted to
    collect enviroment data: `DEPRECATION WARNING: [] is deprecated and will be removed from Rails 6.2`. These deprecation methods
    no longer appear.

    Thanks to Sébastien Dubois (sedubois) for reporting this issue and for the contribution!

  * **Added distributed tracing to Sidekiq jobs**

    Previously, Sidekiq jobs were not included in portions of <a href="https://docs.newrelic.com/docs/understand-dependencies/distributed-tracing/get-started/introduction-distributed-tracing">distributed traces</a> captured by the Ruby agent. Now you can view distributed
    traces that include Sidekiq jobs instrumented by the Ruby agent.

    Thanks to andreaseger for the contribution!

  * **Bugfix: Eliminate warnings appearing when using `add_method_tracer` with Ruby 2.7**

    Previously, using `add_method_tracer` with Ruby 2.7 to trace a method that included keyword arguments resulted in warning messages:
    `warning: Using the last argument as keyword parameters is deprecated; maybe ** should be added to the call`. These messages no
    longer appear.

    Thanks to Harm de Wit and Atsuo Fukaya for reporting the issue!

  ## v6.10.0

  * **Error attributes now added to each span that exits with an error or exception**

    Error attributes `error.class` and `error.message` are now included on the span event in which an error
    or exception was noticed, and, in the case of unhandled exceptions, on any ancestor spans that also exit with an error.
    The public API method `notice_error` now attaches these error attributes to the currently executing span.

    <a href="https://docs.newrelic.com/docs/apm/distributed-tracing/ui-data/understand-use-distributed-tracing-data#rules-limits">Spans with error details are now highlighted red in the Distributed Tracing UI</a>, and error details will expose the associated
    `error.class` and `error.message`.  It is also now possible to see when an exception leaves the boundary of the span,
    and if it is caught in an ancestor span without reaching the entry span. NOTE: This “bubbling up” of exceptions will impact
    the error count when compared to prior behavior for the same trace. It is possible to have a trace that now has span errors
    without the trace level showing an error.

    If multiple errors occur on the same span, only the most recent error information is added to the attributes. Prior errors on the same span are overwritten.

    These span event attributes conform to <a href="https://docs.newrelic.com/docs/agents/manage-apm-agents/agent-data/manage-errors-apm-collect-ignore-or-mark-expected#ignore">ignored errors</a> and <a href="https://docs.newrelic.com/docs/agents/manage-apm-agents/agent-data/manage-errors-apm-collect-ignore-or-mark-expected#expected">expected errors</a>.

  * **Added tests for latest Grape / Rack combination**

    For a short period of time, the latest versions of Grape and Rack had compatibility issues.
    Generally, Rack 2.1.0 should be avoided in all cases due to breaking changes in many gems
    reliant on Rack. We recommend using either Rack <= 2.0.9, or using latest Rack when using Grape
    (2.2.2 at the time of this writing).

  * **Bugfix: Calculate Content-Length in bytes**

    Previously, the Content-Length HTTP header would be incorrect after injecting the Browser Monitoring
    JS when the response contained Unicode characters because the value was not calculated in bytes.
    The Content-Length is now correctly updated.

    Thanks to thaim for the contribution!

  * **Bugfix: Fix Content-Length calculation when response is nil**

    Previously, calculating the Content-Length HTTP header would result in a `NoMethodError` in the case of
    a nil response. These errors will no longer occur in such a case.

    Thanks to Johan Van Ryseghem for the contribution!

  * **Bugfix: DecoratingFormatter now logs timestamps as millisecond Integers**

    Previously the agent sent timestamps as a Float with milliseconds as part of the
    fractional value.  Logs in Context was changed to only accept Integer values and this
    release changes DecoratingFormatter to match.

  * **Added --force option to `newrelic install` cli command to allow overwriting newrelic.yml**

  * **Bugfix: The fully qualified hostname now works correctly for BSD and Solaris**

    Previously, when running on systems such as BSD and Solaris, the agent was unable to determine the fully
    qualified domain name, which is used to help link Ruby agent data with data from New Relic Infrastructure.
    This information is now successfully collected on various BSD distros and Solaris.


  ## v6.9.0

  * **Added support for W3C Trace Context, with easy upgrade from New Relic trace context**

    * [Distributed Tracing now supports W3C Trace Context headers](https://docs.newrelic.com/docs/understand-dependencies/distributed-tracing/get-started/introduction-distributed-tracing#w3c-support)  for HTTP protocols when distributed tracing is enabled. Our implementation can accept and emit both
      the W3C trace header format and the New Relic trace header format. This simplifies
      agent upgrades, allowing trace context to be propagated between services with older
      and newer releases of New Relic agents. W3C trace header format will always be
      accepted and emitted. New Relic trace header format will be accepted, and you can
      optionally disable emission of the New Relic trace header format.

    * When distributed tracing is enabled by setting `distributed_tracing.enabled` to `true`,
      the Ruby agent will now accept W3C's `traceparent` and `tracestate` headers when
      calling `DistributedTracing.accept_distributed_trace_headers` or automatically via
      `http` instrumentation. When calling `DistributedTracing.insert_distributed_trace_headers`,
      or automatically via `http` instrumentation, the Ruby agent will include the W3C
      headers along with the New Relic distributed tracing header, unless the New Relic
      trace header format is disabled by setting `exclude_newrelic_header` setting to `true`.

    * Added `DistributedTracing.accept_distributed_trace_headers` API for accepting both
      New Relic and W3C TraceContext distributed traces.

    * Deprecated `DistributedTracing.accept_distributed_trace_payload` which will be removed
      in a future major release.

    * Added `DistributedTracing.insert_distributed_trace_headers` API for adding outbound
      distributed trace headers. Both W3C TraceContext and New Relic formats will be
      included unless `distributed_tracing.exclude_newrelic_header: true`.

    * Deprecated `DistributedTracing.create_distributed_trace_payload` which will be removed
      in a future major release.

    Known Issues and Workarounds

    * If a .NET agent is initiating traces as the root service, do not upgrade your
      downstream Ruby New Relic agents to this agent release.

  * **Official Ruby 2.7 support**

    The Ruby agent has been verified to run with Ruby 2.7.0.

  * **Reduced allocations when tracing transactions using API calls**

    Default empty hashes for `options` parameter were not frozen, leading to
    excessive and unnecessary allocations when calling APIs for tracing transactions.

    Thanks to Joel Turkel (jturkel) for the contribution!

  * **Bugfix for Resque worker thread race conditions**

    Recent changes in Rack surfaced issues marshalling data for resque, surfaced a potential race-condition with closing out the worker-threads before flushing the data pipe.  This
    is now fixed.

    Thanks to Bertrand Paquet (bpaquet) for the contribution!

  * **Bugfix for Content-Length when injecting Browser Monitoring JS**

    The Content-Length HTTP header would be incorrect after injecting the Browser Monitoring
    JS into the HEAD tag of the HTML source with Content-Length and lead to the HTML BODY content
    being truncated in some cases.  The Content-Length is now correctly updated after injecting the
    Browser Monitoring JS script.

    Thanks to Slava Kardakov (ojab) for the contribution!

  ## v6.8.0

  * **Initial Ruby 2.7 support**

    The Ruby agent has been verified to run with Ruby 2.7.0-preview1.

  * **New API method to add custom attributes to Spans**

    New API method for adding custom attributes to spans.  Previously, custom
    attributes were only available at the Transaction level.  Now, with Span
    level custom attributes, more granular tagging of events is possible for
    easier isolation and review of trace events.  For more information:

    * [`Agent#add_custom_span_attributes`](https://www.rubydoc.info/github/newrelic/newrelic-ruby-agent/NewRelic/Agent#add_custom_span_attributes)

  * **Enables ability to migrate to Configurable Security Policies (CSP) on a per agent
  basis for accounts already using High Security Mode (HSM).**

    When both [HSM](https://docs.newrelic.com/docs/agents/manage-apm-agents/configuration/high-security-mode) and [CSP](https://docs.newrelic.com/docs/agents/manage-apm-agents/configuration/enable-configurable-security-policies) are enabled for an account, an agent (this version or later)
    can successfully connect with either `high_security: true` or the appropriate
    `security_policies_token` configured. `high_security` has been added as part of
    the preconnect payload.

  * **Bugfix for Logs in Context combined with act-fluent-logger-rails**

    Previously, when using the Ruby agent's Logs in Context logger
    to link logging data with trace and entity metadata for an
    improved experience in the UI, customers who were also using
    the `act-fluent-logger-rails` gem would see a `NoMethodError`
    for `clear_tags!` that would interfere with the use of this
    feature. This error no longer appears, allowing customers to
    combine the use of Logs in Context with the use of this gem.

    Please note that the Logs in Context logger does not support
    tagged logging; if you are initializing your logger with a
    `log_tags` argument, your custom tags may not appear on the
    final version of your logs.

  * **Bugfix for parsing invalid newrelic.yml**

    Previously, if the newrelic.yml configuration file was invalid, and the agent
    could not start as a result, the agent would not log any indication of
    the problem.

    This version of the agent will emit a FATAL message to STDOUT when this scenario
    occurs so that customers can address issues with newrelic.yml that prevent startup.

  * **Configuration options containing the terms "whitelist" and "blacklist" deprecated**

    The following local configuration settings have been deprecated:

    * `autostart.blacklisted_constants`: use `autostart.denylisted_constants` instead.
    * `autostart.blacklisted_executables`: use `autostart.denylisted_executables` instead.
    * `autostart.blacklisted_rake_tasks`: use `autostart.denylisted_rake_tasks` instead.
    * `strip_exception_messages.whitelist`: use `strip_exception_messages.allowed_classes` instead.

  * **Bugfix for module loading and constant resolution in Rails**

    Starting in version 6.3, the Ruby agent has caused module loading and constant
    resolution to sometimes fail, which caused errors in some Rails applications.
    These errors were generally `NoMethodError` exceptions or I18n errors
    `translation missing` or `invalid locale`.  These errors would not appear if the agent
    was removed from the application's Gemfile.
    This version of the agent fixes these issues with module loading and constant
    resolution, so these errors no longer occur.

  * **Bugfix: failed to get urandom**

    Previous versions of the agent would fail unexpectedly when the Ruby process used
    every available file descriptor.  The failures would include this message:
    ```
    ERROR : RuntimeError: failed to get urandom
    ```
    This version of the agent uses a different strategy for generating random IDs, and
    will not fail in the same way when no file descriptors are available.

  ## v6.7.0

  * **Trace and Entity Metadata API**

    Several new API methods have been added to the agent:
    * [`Agent#linking_metadata`](https://www.rubydoc.info/github/newrelic/newrelic-ruby-agent/NewRelic/Agent#linking_metadata-instance_method)
    * [`Tracer#trace_id`](https://www.rubydoc.info/github/newrelic/newrelic-ruby-agent/NewRelic/Agent/Tracer#trace_id-class_method)
    * [`Tracer#span_id`](https://www.rubydoc.info/github/newrelic/newrelic-ruby-agent/NewRelic/Agent/Tracer#span_id-class_method)
    * [`Tracer#sampled?`](https://www.rubydoc.info/github/newrelic/newrelic-ruby-agent/NewRelic/Agent/Tracer#sampled?-class_method)

    These API methods allow you to access information that can be used to link data of your choosing to a trace or entity.

  * **Logs in Context**

    This version of the agent includes a logger, which can be used in place of `::Logger`
    from the standard library, or `ActiveSupport::Logger` from Rails.  This logger
    leverages the new trace and entity metadata API to decorate log statements with entity
    and trace metadata, so they can be correlated together in the New Relic UI.

    For more information on how to use logs in context, see https://docs.newrelic.com/docs/enable-logs-context-ruby

  * **Project metadata in Gemspec**

     Project metadata has been added to the gemspec file. This means our Rubygems page will allow users to more easily
     access the agent's source code, raise issues, and read the changelog.

     Thanks to Orien Madgwick for the contribution!

## v6.6.0

  * **Bugfix for ActionCable Instrumentation**

    Previous versions of the agent sometimes caused application crashes with some versions
    of ActionCable.  The application would exit quickly after startup with the error:
    `uninitialized constant ActionCable::Engine`.

    Version 6.6.0 of the agent no longer crashes in this way.


  * **Handling of disabling Error Collection**

    When the agent first starts, it begins collecting Error Events and Traces before
    fetching configuration from New Relic.  In previous versions of the agent, those
    events or traces would be sent to New Relic, even if _Error Collection_ is disabled in
    the application's server-side configuration.

    Version 6.6.0 of the agent drops all collected Error Events and Traces if the
    configuration from the server disables _Error Collection_.

## v6.5.0

* **Change to default setting for ActiveRecord connection resolution**

  Due to incompatibilities between the faster ActiveRecord connection resolution
  released in v6.3.0 of the agent and other gems which patch ActiveRecord,
  `backport_fast_active_record_connection_lookup` will now be set to `false` by default.
  Because it results in a significant performance improvement, we recommend customers
  whose environments include ActiveRecord change this setting to `true`
  _unless_ they are using other gems which measure ActiveRecord performance, which may
  lose functionality when combined with this setting. If unsure whether to enable
  `backport_fast_active_record_connection_lookup`, we recommend enabling it in a
  development environment to make sure other gems which patch ActiveRecord are still
  working as expected.

* **Bugfix for ActiveStorage instrumentation error**

  Version 6.4.0 of the agent introduced a bug that interfered with ActiveStorage
  callbacks, resulting in the agent being unable to instrument ActiveStorage operations.
  ActiveStorage segments are now correctly recorded.

* **Bugfix for ActiveRecord 4.1 and 4.2 exception logging**

  Version 6.3.0 of the agent introduced a bug that prevented ActiveRecord versions 4.1
  and 4.2 from logging exceptions that occurred within a database transaction.  This
  version of the agent restores the exception logging functionality from previous agent
  versions.
  Thanks to Oleksiy Kovyrin for the contribution!

## v6.4.0

* **Custom Metadata Collection**

  The agent now collects environment variables prefixed by `NEW_RELIC_METADATA_`.  These
  may be added to transaction events to provide context between your Kubernetes cluster
  and your services.  For details on the behavior, see
  [this blog post](https://blog.newrelic.com/engineering/monitoring-application-performance-in-kubernetes/).

* **Bugfix for faster ActiveRecord connection resolution**

  Version 6.3.0 of the agent backported the faster ActiveRecord connection resolution
  from Rails 6.0 to previous versions, but the implementation caused certain other gems
  which measured ActiveRecord performance to stop working. This version of the agent
  changes the implementation of this performance improvement so no such conflicts occur.

* **Bugfix for Grape instrumentation error**

  Previous versions of the agent would fail to install Grape instrumentation in Grape
  versions 1.2.0 and up if the API being instrumented subclassed `Grape::API::Instance`
  rather than `Grape::API`.  A warning would also print to the newrelic_agent log:
  ```
  WARN : Error in Grape instrumentation
  WARN : NoMethodError: undefined method `name' for nil:NilClass
  ```

  This version of the agent successfully installs instrumentation for subclasses
  of `Grape::API::Instance`, and these log messages should no longer appear.

* **Bugfix for streaming responses**

  Previous versions of the agent would attempt to insert JavaScript instrumentation into
  any streaming response that did not make use of `ActionController::Live`.  This resulted
  in an empty, non-streamed response being sent to the client.

  This version of the agent will not attempt to insert JavaScript instrumentation into
  a response which includes the header `Transfer-Encoding=chunked`, which indicates a
  streaming response.

  This should exclude JavaScript instrumentation for all streamed responses.  To include
  this instrumentation manually, see
  [Manually instrument via agent API](https://docs.newrelic.com/docs/agents/ruby-agent/features/new-relic-browser-ruby-agent#manual_instrumentation)
  in our documentation.

## v6.3.0

  * **Official Rails 6.0 support**

    This version of the agent has been verified against the Rails 6.0.0 release.

    As ActiveRecord 4, 5, and 6 use the same New Relic instrumentation, the
    `disable_active_record_4` and `disable_active_record_5` settings in NewRelic.yml are being
    deprecated in favor of the new `disable_active_record_notifications`.  This new
    setting will affect the instrumentation of ActiveRecord 4, 5, and 6. The deprecated settings
    will be removed in a future release.

  * **Bugfix for `newrelic deployments` script**

    For applications housed in the EU, the `newrelic deployments` script included with previous
    versions of the agent would fail with the following message: `Deployment not recorded:
    Application does not exist.` This is because the script would attempt to send the deployment
    notification to the US region. The deployment script now sends deployments to the correct region.

  * **Faster ActiveRecord connection resolution**

    This version of the agent uses the faster ActiveRecord connection resolution that Rails 6.0 uses, even on previous versions of Rails.
    Thanks to Callum Jones for the contribution!

  * **Support non-ascii characters in hostnames**

    Previous versions of the agent would frequently log warnings like: `log writing failed.  "\xE2" from ASCII-8BIT to UTF-8` if the hostname contained a non-ascii character.  This version of the agent will no longer log these warnings.
    Thanks to Rafael Petry for the contribution!

## v6.2.0

  * Bugfix for superfluous `Empty JSON response` error messages

    Version 6.1.0 of the agent frequently logged error messages about an empty
    JSON response, when no error had occurred.  These logs no longer appear.

  * Bugfix for `Unable to calculate elapsed transaction time` warning messages

    Ruby Agent versions 5.4 through 6.1, when running in jruby without
    ObjectSpace enabled, would occasionally log a warning indicating that the
    agent was unable to calculate the elapsed transaction time.  When this log
    statement appeared, the affected transactions would not be included in the
    data displayed on the capacity analysis page.  These transactions are now
    correctly recorded.

## v6.1.0

   * Performance monitoring on Kubernetes

     This release adds Transaction event attributes that provide
     context between your Kubernetes cluster and services. For details
     on the benefits, see this [blog
     post](https://blog.newrelic.com/engineering/monitoring-application-performance-in-kubernetes/).

   * Bugfix for Bunny instrumentation when popping empty queues

     When a customer calls `Bunny::Queue#pop` on an empty queue, Bunny
     returns a `nil` value.  Previous Ruby Agent versions raised a
     `NoMethodError` when trying to process this result.  Now, the
     agent correctly skips processing for `nil` values.  Thanks to
     Matt Campbell for the contribution.

## v6.0.0

   * Tracer API for flexible custom instrumentation

     With agent version 6.0, we are introducing the `Tracer` class, an
     officially supported public API for more flexible custom
     instrumentation.  By calling its `in_transaction` method, you can
     instrument an arbitrary section of Ruby code without needing to
     juggle any explicit state.  Behind the scenes, the agent will
     make sure that the measured code results in an APM segment inside
     a transaction.

     The same API contains additional methods for creating
     transactions and segments, and for interacting with the current
     transaction.  For more details, see the [custom instrumentation
     documentation](https://docs.newrelic.com/docs/agents/ruby-agent/api-guides/ruby-custom-instrumentation).

     If you were previously using any of the agent's private,
     undocumented APIs, such as `Transaction.wrap` or
     `Transaction.start/stop`, you will need to update your code to
     use the Tracer API.

     The full list of APIs that were removed or deprecated are:
       * `External.start_segment`
       * `Transaction.create_segment`
       * `Transaction.start`
       * `Transaction.stop`
       * `Transaction.start_datastore_segment`
       * `Transaction.start_segment`
       * `Transaction.wrap`
       * `TransactionState.current_transaction`

     If are you using any of these APIs, please see the [upgrade guide](https://docs.newrelic.com/docs/agents/ruby-agent/troubleshooting/update-private-api-calls-public-tracer-api) for a list of replacements.

   * Agent detects Rails 6.0

     The agent properly detects Rails 6.0 and no longer logs an error when
     started in a Rails 6.0 environment. This does not include full Rails 6.0
     support, which will be coming in a future release. Thanks to Jacob Bednarz
     for the contribution.

## v5.7.0

   * Ruby 2.6 support

     We have tested the agent with the official release of Ruby 2.6.0
     made on December 25, 2018, and it looks great! Feel free to use
     agent v5.7 to measure the performance of your Ruby 2.6
     applications.

   * Support for loading Sequel core standalone

     Earlier versions of the agent required users of the Sequel data
     mapping library to load the _entire_ library.  The agent will now
     enable Sequel instrumentation when an application loads Sequel's
     core standalone; i.e., without the `Sequel::Model` class.  Thanks
     to Vasily Kolesnikov for the contribution!

   * Grape 1.2 support

     With agent versions 5.6 and earlier, Grape 1.2 apps reported
     their transactions under the name `Proc#call` instead of the name
     of the API endpoint.  Starting with agent version 5.7, all
     existing versions of Grape will report the correct transaction
     name.  Thanks to Masato Ohba for the contribution!

## v5.6.0

  * Bugfix for transactions with `ActionController::Live`

    Previously, transactions containing `ActionController::Live` resulted in
    incorrect calculations of capacity analysis as well as error backtraces
    appearing in agent logs in agent versions 5.4 and later. The agent now
    correctly calculates capacity for transactions with `ActionController::Live`.

  * Add ability to exclude attributes from span events and transaction
    segments

    Agent versions 5.5 and lower could selectively exclude attributes
    from page views, error traces, transaction traces, and
    transaction events.  With agent version 5.6 and higher, you can
    also exclude attributes from span events (via the
    `span_events.include/exclude` options) and from transaction
    segments (via the `transaction_segments.include/exclude` options).

    As with other attribute destinations, these new options will
    inherit values from the top-level `attributes.include/exclude`
    settings. See the
    [documentation](https://docs.newrelic.com/docs/agents/ruby-agent/attributes/enabling-disabling-attributes-ruby)
    for more information.

  * Increasing backoff sequence on failing to connect to New Relic

    If the agent cannot reach New Relic, it will now wait for an
    increasing amount of time after each failed attempt.  We are also
    starting with a shorter delay initially, which will help customer
    apps bounce back more quickly from transient network errors.

  * Truncation of long stack traces

    Previous versions of the agent would truncate long stack traces to
    50 frames.  To give customers more flexibility, we have added the
    `error_collector.max_backtrace_frames` configuration option.
    Thanks to Patrick Tulskie for the contribution!

  * Update link in documentation

    The community forum link in `README.md` now goes to the updated
    location.  Thanks to Sam Killgallon for the contribution!

  * Active Storage instrumentation

    The agent now provides instrumentation for Active Storage, introduced in
    Rails 5.2. Customers will see Active Storage operations represented as
    segments within transaction traces.

## v5.5.0

  * Bugfix for `perform` instrumentation with curb gem

    Use of curb's `perform` method now no longer results in nil headers
    getting returned.

  * Bugfix for parsing Docker container IDs

    The agent now parses Docker container IDs correctly regardless of the
    cgroup parent.

  * Use lazy load hooks for ActiveJob instrumentation

    In some instances the ActiveJob instrumentation could trigger ActiveJob
    to load before it was initialized by Rails. This could result in
    configuration changes not being properly applied. The agent now uses lazy
    load hooks which fixes this issue.

  * Documentation improvement

    The `config.dot` diagram of the agent's configuration settings no
    longer includes the deleted `developer_mode` option.  Thanks to
    Yuichiro Kaneko for the contribution!

## v5.4.0

  * Capacity analysis for multi-threaded dispatchers

    Metrics around capacity analysis did not previously account for multi-threaded
    dispatchers, and consequently could result in capacities of over 100% being
    recorded. This version now properly accounts for multi-threaded dispatchers.

  * `NewRelic::Agent.disable_transaction_tracing` deprecated

    `NewRelic::Agent.disable_transaction_tracing` has been deprecated. Users
    are encouraged to use `NewRelic::Agent.disable_all_tracing` or
    `NewRelic::Agent.ignore_transaction` instead.

  * Bugfix for SQL over-obfuscation

    A bug, introduced in v5.3.0, where SQL could be over-obfuscated for some
    database adapters has been fixed.

  * Bugfix for span event data in Resque processes

    A bug where span events would not be sent from Resque processes due to a
    missing endpoint has been fixed.

## v5.3.0 ##

  * Distributed Tracing

    Distributed tracing lets you see the path that a request takes as
    it travels through your distributed system. By showing the
    distributed activity through a unified view, you can troubleshoot
    and understand a complex system better than ever before.

    Distributed tracing is available with an APM Pro or equivalent
    subscription. To see a complete distributed trace, you need to
    enable the feature on a set of neighboring services. Enabling
    distributed tracing changes the behavior of some New Relic
    features, so carefully consult the
    [transition guide](https://docs.newrelic.com/docs/transition-guide-distributed-tracing)
    before you enable this feature.

    To enable distributed tracing, set the
    `distributed_tracing.enabled` configuration option to `true`.

## v5.2.0 ##

  * Use priority sampling for errors and custom events

    Priority sampling replaces the older reservoir event sampling method.
    With this change, the agent will maintain randomness across a given
    time period while improving coordination among transactions, errors,
    and custom events.

  * Bugfix for wrapping datastore operations

    The agent will now complete the process of wrapping datastore
    operations even if an error occurs during execution of a callback.

  * Span Events

    Finished segments whose `sampled` property is `true` will now post
    Span events to Insights.

## v5.1.0 ##

  * Rails 5.2 support

    The Ruby agent has been validated against the latest release of
    Ruby on Rails!

  * Support for newer libraries and frameworks

    We have updated the multiverse suite to test the agent against
    current versions of several frameworks.

  * Add `custom_attributes.enabled` configuration option

    This option is enabled by default. When it's disabled, custom
    attributes will not be transmitted on transaction events or error
    events.

  * Fix Grape load order dependency

    The agent will now choose the correct name for Grape transactions
    even if the customer's app loads the agent before Grape. Thanks
    to Daniel Doubrovkine for the contribution!

  * Add `webpacker:compile` to blacklisted tasks

    `webpacker:compile` is commonly used for compiling assets. It has
    been added to `AUTOSTART_BLACKLISTED_RAKE_TASKS` in the default
    configuration. Thanks to Claudio B. for the contribution!

  * Make browser instrumentation W3C-compliant

    `type="text/javascript"` is optional for the `<script>` tag under
    W3C. The `type` attribute has now been removed from browser
    instrumentation. Thanks to Spharian for the contribution!

  * Deferred `add_method_tracer` calls

    If a third-party library calls `add_method_tracer` before the
    agent has finished starting, we now queue these calls and run them
    when it's safe to do so (rather than skipping them and logging a
    warning).

  * Bugfix for Resque `around` / `before` hooks

    In rare cases, the agent was not instrumenting Resque `around` and
    `before` hooks. This version fixes the error.

  * Truncation of long stack traces

    Occasionally, long stack traces would cause complications sending
    data to New Relic. This version truncates long traces to 50 frames
    (split evenly between the top and bottom of the trace).

## v5.0.0 ##

  * SSL connections to New Relic are now mandatory

    Prior to this version, using an SSL connection to New Relic was
    the default behavior, but could be overridden. SSL connections are
    now enforced (not overrideable).

  * Additional security checking before trying to explain
    multi-statement SQL queries

    Customer applications might submit SQL queries containing multiple
    statements (e.g., SELECT * FROM table; SELECT * FROM table).  For
    security reasons, we should not generate explain plans in this
    situation.

    Although the agent correctly skipped explain plans for these
    queries during testing, we have added extra checks for this
    scenario.

  * Bugfix for RabbitMQ exchange names that are symbols

    The agent no longer raises a TypeError when a RabbitMQ exchange
    name is a Ruby symbol instead of a string.

  * Bugfix for audit logging to stdout

    Previous agents configured to log to stdout would correctly send
    regular agent logs to stdout, but would incorrectly send audit
    logs to a text file named "stdout".  This release corrects the
    error.

  * Bugfix for Capistrano deployment notifications on v3.7 and beyond

    Starting with version 3.7, Capistrano uses a different technique
    to determine a project's version control system.  The agent now
    works correctly with this new behavior. Thanks to Jimmy Zhang for
    the contribution.

## v4.8.0 ##

  * Initialize New Relic Agent before config initializers

  When running in a Rails environment, the agent registers an initializer that
  starts the agent. This initializer is now defined to run before config/initializers.
  Previously, the ordering was not specified for the initializer. This change
  guarantees the agent will started by the time your initializers run, so you can
  safely reference the Agent in your custom initializers. Thanks to Tony Ta for
  the contribution.

  * Ruby 2.5 Support

  The Ruby Agent has been verified to run under Ruby 2.5.

  * `request.uri` Collected as an Agent Attribute

  Users can now control the collection of `request.uri` on errors and transaction
  traces. Previously it was always collected without the ability to turn it off.
  It is now an agent attribute that can be controlled via the attributes config.
  For more information on agent attributes [see here](https://docs.newrelic.com/docs/agents/manage-apm-agents/agent-data/agent-attributes).

## 4.7.1 ##

  * Bugfix for Manual Browser Instrumentation

  There was a previous bug that required setting both `rum.enabled: false` and
  `browser.auto_instrument: false` to completely disable browser monitoring. An
  attempt to fix this in 4.7.0 resulted in breaking manual browser
  instrumentation. Those changes have been reverted. We will revisit this issue
  in an upcoming release.

## v4.7.0 ##

  * Expected Error API

  The agent now sends up `error.expected` as an intrinsic attribute on error
  events and error traces. When you pass `expected: true` to the `notice_error`
  method, both Insights and APM will indicate that the error is expected.

  * Typhoeus Hydra Instrumentation

  The agent now has request level visibility for HTTP requests made using
  Typhoeus Hydra.

  * Total Time Metrics are Recorded

  The agent now records Total Time metrics. In an application where segments
  execute concurrently, the total time can exceed the wall-clock time for a
  transaction. Users of the new Typhoeus Hydra instrumentation will notice
  this as changes on the overview page. Immediately after upgrading there
  will be an alert in the APM dashboard that states: "There are both old and
  new time metrics for this time window". This indicates that during that time
  window, some transactions report the total time metrics, while others do not.
  The message will go away after waiting for enough time to elapse and / or
  updating the time window.

  * Add `:message` category to `set_transaction_name` public API method

  The agent now permits the `:message` category to be passed into the public
  API method `set_transaction_name`, which will enable the transaction to be
  displayed as a messaging transaction.

  * Create `prepend_active_record_instrumentation` config option

  Users may now set the `prepend_active_record_instrumentation` option in
  their agent config to install Active Record 3 or 4 instrumentation using
  `Module.prepend` rather than `alias_method`.

  * Use Lazy load hooks for `ActionController::Base` and `ActionController::API`

  The agent now uses lazy load hooks to hook on `ActionController::Base` and
  `ActionController::API`. Thanks Edouard Chin for the contribution!

  * Use Lazy load hooks for `ActiveRecord::Base` and `ActiveRecord::Relation`

  The agent uses lazy load hooks when recording supportability metrics
  for `ActiveRecord::Base` and `ActiveRecord::Relation`. Thanks Joseph Haig
  for the contribution!

  * Check that `Rails::VERSION` is defined instead of just `Rails`

  The agent now checks that `Rails::VERSION` is defined since there are cases
  where `Rails` is defined but `Rails::VERSION` is not. Thanks to Alex Riedler
  and nilsding for the contribution!

  * Support fast RPC/direct reply-to in RabbitMQ

  The agent can now handle the pseudo-queue 'amq.rabbitmq.reply-to' in its
  Bunny instrumentation. Previously, using fast RPC led to a `NoMethodError`
  because the reply-to queue was expected to be a `Queue` object instead of
  a string.

## v4.6.0 ##

  * Public API for External Requests

  The agent now has public API for instrumenting external requests and linking
  up transactions via cross application tracing. See the [API Guide](https://docs.newrelic.com/docs/agents/ruby-agent/customization/ruby-agent-api-guide#externals)
  for more details this new functionality.

## v4.5.0 ##

  * Send synthetics headers even when CAT disabled

  The agent now sends synthetics headers whenever they are received from an
  external request, even if cross-application tracing is disabled.

  * Bugfix for DelayedJob Daemonization

  Customers using the delayed_job script that ships with the gem may encounter
  an IOError with a message indicating the stream was closed. This was due to
  the agent attempting to write a byte into a Pipe that was closed during the
  deamonization of the delayed_job script. This issue has been fixed.

  * Collect supportability metrics for public API

  The agent now collects Supportability/API/{method} metrics to track usage of
  all methods in the agent's public API.

  * Collect supportability metrics on `Module#prepend`

  The agent now collects Supportability/PrependedModules/{Module} metrics
  for ActiveRecord 4 and 5, ActionController 4 and 5, ActionView 4 and 5,
  ActiveJob 5, and ActionCable 5. These help track the adoption of the
  `Module#prepend` method so we can maintain compatibility with newer versions
  of Ruby and Rails.

  * Collect explain plans when using PostGIS ActiveRecord adapter

  The agent will now collect slow SQL explain plans, if configured to, on
  connections using the PostGIS adapter. Thanks Ari Pollak for the contribution!

  * Lazily intialize New Relic Config

  The agent will lazily initialize the New Relic config. This allows the agent
  to pickup configuration from environment variables set by dotenv and similar
  tools.

## v4.4.0 ##

  * Include test helper for 3rd party use

  In 4.2.0, all test files were excluded from being packaged in the gem. An
  agent class method `NewRelic::Agent.require_test_helper` was used by 3rd
  party gem authors to test extensions to the agent. The required file is now
  included in the gem.

  * Collect cloud metadata from Azure, GCP, PCF, and AWS cloud platform

  The agent now collects additional metadata when running in AWS, GCP, Azure, and
  PCF. This information is used to provide an enhanced experience when the agent
  is deployed on those platforms.

  * Install `at_exit` hook when running JRuby

  The agent now installs an `at_exit` hook when running JRuby, which wasn't
  done before because of constraints related to older JRuby versions that
  are no longer supported.

  * User/Utilization and System/Utilization metrics not recorded after Resque forks

  The agent no longer records invalid User/Utilization and System/Utilization
  metrics, which can lead to negative values, in forks of Resque processes.

  * Add `identifier` field to agent connect settings

  The agent now includes a unique identifier in its connect settings, ensuring
  that when multiple agents connect to multiple different apps, data are reported
  for each of the apps.

  * Clear transaction state after forking now opt-in

  The agent waits to connect until the first web request when it detects it's
  running in a forking dispatcher. When clearing the transaction state in this
  situation we lose the first frame of the transaction and the subsequent
  trace becomes corrupted. We've made this feature opt-in and is turned off by
  default. This behavior only affects the first transaction after a dispatcher
  forks.

## v4.3.0 ##

  * Instrumentation for the Bunny AMQP Client

  The Bunny AMQP Client is now automatically instrumented. The agent will
  report data for messages sent and received by an application. Data on messages
  is available in both APM and Insights. Applications connected through a
  RabbitMQ exchange will now also be visible on Service Maps as part of Cross
  Application Tracing. See the [message queues documentation page](https://docs.newrelic.com/docs/agents/ruby-agent/features/message-queues)
  for more details.

  * Safely normalize external hostnames

  The agent has been updated to check for nil host values before downcasing the
  hostname. Thanks Rafael Valério for the contribution!

  * PageView events will not be generated for ignored transactions

  The agent now checks if transaction is ignored before injecting the New Relic
  Browser Agent. This will prevent PageView events from being generated for
  ignored transactions.

  * Datastores required explicitly in agent

  The agent has been modified to explicity `require` the Datastores module
  whereas previously there were situations where the module could be
  implicitly defined. Thanks Kevin Griffin for the contribution!

  * Clear transaction state after forking

  Previously, if a transaction was started and the process forks, the transaction
  state survived the fork and `#after_fork` call in thread local storage. Now,
  this state is cleared by `#after_fork`.

  * Postgis adapter reports as Postgres for datastores

  The agent now maps the Postgis adapter to Postgres for datastore metrics.
  Thanks Vojtěch Vondra for the contribution!

  * Deprecate `:trace_only` option

  The `NewRelic::Agent.notice_error` API has been updated to deprecate the
  `:trace_only` option in favor of `:expected`.

## v4.2.0 ##

  * Sinatra 2.0 and Padrino 0.14.x Support

  The agent has been verified against the latest versions of Sinatra and Padrino.

  * Rails 5.1 Support

  The Ruby agent has been validated against the latest release of Ruby on Rails!

  * APP_ENV considered when determining environment

  The agent will now consider the APP_ENV environment when starting up.

  * Test files excluded from gem

  The gemspec has been updated to exclude test files from being packaged into the
  gem. Thanks dimko for the contribution!

## v4.1.0 ##

  * Developer Mode removed

  The Ruby Agent's Developer Mode, which provided a very limited view of your
  application performance data, has been removed. For more information, check
  out our [community forum](https://discuss.newrelic.com/t/feedback-on-the-ruby-agent-s-developer-mode/46957).

  * Support NEW_RELIC_ENV for Rails apps

  Previously, users could set the agent environment with NEW_RELIC_ENV only
  for non-Rails apps. For Rails app, the agent environment would use whatever
  the Rails environment was set to. Now, NEW_RELIC_ENV can also be used for
  Rails apps, so that it is possible to have an agent environment that is
  different from the Rails environment. Thanks Andrea Campolonghi for the
  contribution, as well as Steve Schwartz for also looking into this issue!

  * Normalization of external hostnames

  Hostnames from URIs used in external HTTP requests are now always downcased
  to prevent duplicate metrics when only case is different.

## v4.0.0 ##

  * Require Ruby 2.0.0+

  The agent no longer supports Ruby versions prior to 2.0, JRuby 1.7 and
  earlier, and all versions of Rubinius. Customers using affected Rubies
  can continue to run 3.x agent versions, but new features or bugfixes
  will not be published for 3.x agents. For more information, check out our
  [community forum](https://discuss.newrelic.com/t/support-for-ruby-jruby-1-x-is-being-deprecated-in-ruby-agent-4-0-0/44787).

  * OkJson vendored library removed

  Ruby 1.8 did not include the JSON gem by default, so the agent included a
  vendored version of [OkJson](https://github.com/kr/okjson) that it would fall
  back on using in cases where the JSON gem was not available. This has been
  removed.

  * YAJL workaround removed

  [yajl-ruby](https://github.com/brianmario/yajl-ruby) versions prior to 1.2 had
  the potential to cause a segmentation fault when working large, deeply-nested
  objects like thread profiles. If you are using yajl-ruby with the `JSON`
  monkey patches enabled by requiring `yajl/json_gem`, you should upgrade to
  at least version 1.2.

  * Deprecated APIs removed

    * `Agent.abort_transaction!`
    * `Agent.add_custom_parameters`
    * `Agent.add_request_parameters`
    * `Agent.browser_timing_footer`
    * `Agent.get_stats`
    * `Agent.get_stats_no_scope`
    * `Agent.record_transaction`
    * `Agent.reset_stats`
    * `Agent.set_user_attributes`
    * `Agent::Instrumentation::Rack`
    * `ActionController#newrelic_notice_error`
    * `ActiveRecordHelper.rollup_metrics_for` (may be incompatible with newrelic_moped)
    * `Instrumentation::MetricFrame.recording_web_transaction?`
    * `Instrumentation::MetricFrame.abort_transaction!`
    * `MethodTracer.get_stats_scoped`
    * `MethodTracer.get_stats_unscoped`
    * `MethodTracer.trace_method_execution`
    * `MethodTracer.trace_method_execution_no_scope`
    * `MethodTracer.trace_method_execution_with_scope`
    * `MetricSpec#sub`
    * `MetricStats#get_stats`
    * `MetricStats#get_stats_no_scope`
    * `NoticedError#exception_class`
    * `Rack::ErrorCollector`
    * `StatsEngine::Samplers.add_sampler`
    * `StatsEngine::Samplers.add_harvest_sampler`

  The above methods have had deprecation notices on them for some time and
  have now been removed. Assistance migrating usage of these APIs is
  available at https://docs.newrelic.com/node/2601.

  The agent no longer deletes deprecated keys passed to `add_method_tracer`. Passing
  in deprecated keys can cause an exception. Ensure that you are not passing any of
  the following keys: `:force, :scoped_metric_only, :deduct_call_time_from_parent`
  to `add_method_tracer`.

  The agent no longer deletes deprecated keys passed in as options to
  `NewRelic::Agent.notice_error`. If you are passing any of these deprecated
  keys: `:request_params, :request, :referer` to the `notice_error` API, please
  delete them otherwise they will be collected as custom attributes.

  * Error handling changes

  The agent now only checks for `original_exception` in environments with Rails
  versions prior to 5. Checking for `Exception#cause` has been removed. In addition,
  the agent now will match class name with message and backtrace when noticing
  errors that have an `original_exception`.

## v3.18.1 ##

  * Ensure Mongo aggregate queries are properly obfuscated

  Instrumentation for the Mongo 2.x driver had a bug where the `pipeline`
  attribute of Mongo aggregate queries was not properly obfuscated. Users
  who have sensitive data in their `aggregate` queries are strongly encouraged
  to upgrade to this version of the agent. Users who are unable to upgrade are
  encouraged to turn off query collection using by setting
  `mongo.capture_queries` to false in their newrelic.yml files.

  This release fixes [New Relic Security Bulletin NR17-03](https://docs.newrelic.com/docs/accounts-partnerships/accounts/security-bulletins/security-bulletin-nr17-03).

  * Early access Redis 4.0 instrumentation

  Our Redis instrumentation has been tested against Redis 4.0.0.rc1.

## v3.18.0 ##

  * Ruby 2.4.0 support

  The agent is now tested against the official release of ruby 2.4.0,
  excluding incompatible packages.

  * Agent-based metrics will not be recorded outside of active transactions

  The agent has historically recorded metrics outside of a transaction. In
  practice, this usually occurs in applications that run background job
  processors. The agent would record metrics for queries the
  background job processor is making between transactions. This can lead
  to display issues on the background overview page and the presence of
  metrics generated by the background job processor can mask the application
  generated metrics on the database page. The agent will no longer generate
  metrics outside of a transaction. Custom metrics recorded using
  `NewRelic::Agent.record_metric` will continue to be recorded regardless
  of whether there is an active transaction.

  * Include ControllerInstrumentation module with ActiveSupport.on_load

  The agent will now use the `on_load :action_controller` hook to include
  the ControllerInstrumentation module in to both the `Base` and `API`
  classes of ActionController for Rails 5. This ensures that the proper
  load order is retained, minimizing side-effects of having the agent in
  an application.

  * Ensure values for revisions on Capistrano deploy notices

  Previously, running the task to look up the changelog could
  generate an error, if there weren't previous and current revisions
  defined. This has now been fixed. Thanks Winfield Peterson for the
  contribution!

  * External Segment Rewrites

  The agent has made internal changes to how it represents segments for
  external web requests.

## v3.17.2 ##

  * compatibility with ruby 2.4.0-preview3

  the ruby agent has been updated to work on ruby 2.4.0-preview3.

  * Early Access Sinatra 2.0 instrumentation

  Our Sinatra instrumentation has been updated to work with Sinatra
  2.0.0.beta2.

  * Include controller instrumentation module in Rails 5 API

  The agent now includes the ControllerInstrumentation module into
  ActionController::API. This gives Rails API controllers access to
  helper methods like `newrelic_ignore` in support of the existing
  event-subscription-based action instrumentation. Thanks Andreas
  Thurn for the contribution!

  * Use Module#prepend for ActiveRecord 5 Instrumentation

  Rails 5 deprecated the use of `alias_method_chain` in favor of using
  `Module#prepend`. Mixing `Module#prepend` and `alias_method_chain`
  can lead to a SystemStackError when an `alias_method_chain` is
  applied after a module has been prepended. This should ensure
  better compatibility between our ActiveRecord Instrumentation and
  other third party gems that modify ActiveRecord using `Module#prepend`.

  * Use license key passed in to NewRelic::Agent.manual_start

  Previously, the license key passed in when manually starting the agent
  with NewRelic::Agent.manual_start was not referenced when setting up
  the connection to report data to New Relic. This is now fixed.

  * Account for DataMapper database connection errors

  Our DataMapper instrumentation traces instances of DataObjects::SQLError
  being raised and removes the password from the URI attribute. However,
  when DataObjects cannot connect to the database (ex: could not resolve
  host), it will raise a DataObjects::ConnectionError. This inherits from
  DataObjects::SQLError but has `nil` for its URI attribute, since no
  connection has been made yet. To avoid the password check here on `nil`,
  the agent catches and re-raises any instances of DataObjects::ConnectionError
  explicitly. Thanks Postmodern for this contribution!

  * Account for request methods that require arguments

  When tracing a transaction, the agent tries to get the request object
  from a controller if it wasn't explicitly passed in. However, this posed
  problems in non-controller transactions with their own `request` methods
  defined that required arguments, such as in Resque jobs. This is now fixed.

## v3.17.1 ##

  * Datastore instance reporting for Redis, MongoDB, and memcached

  The agent now collects datastore instance information for Redis, MongoDB,
  and memcached. This information is displayed in transaction traces and slow
  query traces. For memcached only, multi requests will expand to individual
  server nodes, and the operation and key(s) will show in the trace details
  "Database query" section. Metrics for `get_multi` nodes will change slightly.
  Parent nodes for a `get_multi` will be recorded as generic segments. Their
  children will be recorded as datastore segments under the name
  `get_multi_request` and represent a batch request to a single Memcached
  instance.

  * Rescue errors from attempts to fetch slow query explain plans

  For slow queries through ActiveRecord 4+, the agent will attempt to fetch
  an explain plan on SELECT statements. In the event that this causes an
  error, such as being run on an adapter that doesn't implement `exec_query`,
  the agent will now rescue and log those errors.

## v3.17.0 ##

  * Datastore instance reporting for ActiveRecord

  The agent now collects database instance information for ActiveRecord operations,
  when using the MySQL and Postgres adapters.  This information (database server
  and database name) is displayed in transaction traces and slow query traces.

## v3.16.3 ##

  * Add `:trace_only` option to `notice_error` API

  Previously, calling `notice_error` would record the trace, increment the
  error count, and consider the transaction failing for Apdex purposes. This
  method now accepts a `:trace_only` boolean option which, if true, will only
  record the trace and not affect the error count or transaction.

  * HTTP.rb support

  The agent has been updated to add instrumentation support for the HTTP gem,
  including Cross Application Tracing. Thanks Tiago Sousa for the contribution!

  * Prevent redundant Delayed::Job instrumentation installation

  This change was to handle situations where multiple Delayed::Worker instances
  are being created but Delayed::Job has already been instrumented. Thanks Tony
  Brown for the contribution!

## v3.16.2 ##

  * Fix for "Unexpected frame in traced method stack" errors

  Our ActiveRecord 4.x instrumentation could have generated "Unexpected frame in
  traced method stack" errors when used outside of an active transaction (for
  example, in custom background job handlers). This has been fixed.

## v3.16.1 ##

  * Internal datastore instrumentation rewrites

  The agent's internal tracing of datastore segments has been rewritten, and
  instrumentation updated to utilize the new classes.

  * Fix Grape endpoint versions in transaction names

  Grape 0.16 changed Route#version (formerly #route_version) to possibly return
  an Array of versions for the current endpoint. The agent has been updated to
  use rack.env['api.version'] set by Grape, and fall back to joining the version
  Array with '|' before inclusion in the transaction name when api.version is
  not available. Thanks Geoff Massanek for the contribution!

  * Fix deprecation warnings from various Rails error subclasses

  Rails 5 deprecates #original_exception on a few internal subclasses of
  StandardError in favor of Exception#cause from Ruby stdlib. The agent has
  been updated to try Exception#cause first, thus avoiding deprecation
  warnings. Thanks Alexander Stuart-Kregor for the contribution!

  * Fix instrumentation for Sequel 4.35.0

  The latest version of Sequel changes the name and signature of the method
  that the Ruby Agent wraps for instrumentation. The agent has been updated
  to handle these changes. Users using Sequel 4.35.0 or newer should upgrade
  their agent.

  * Fix DataMapper instrumentation for additional versions

  Different versions of DataMapper have different methods for retrieving the
  adapter name, and Postmodern expanded our coverage. Thanks for the
  contribution!

## v3.16.0 ##

  * Official Rails 5.0 support

  This version of the agent has been verified against the Rails 5.0.0 release.

  * Early access Action Cable instrumentation

  The Ruby agent instruments Action Cable channel actions and calls to
  ActionCable::Channel#Transmit in Rails 5. Feedback is welcome!

  * Obfuscate queries from `oracle_enhanced` adapter correctly

  This change allows the `oracle_enhanced` adapter to use the same
  obfuscation as `oracle` adapters. Thanks Dan Drinkard for the contribution!

  * Make it possible to define a newrelic_role for deployment with Capistrano 3

  Thanks NielsKSchjoedt for the contribution!

  * Retry initial connection to New Relic in Resque master if needed

  Previously, if the initial connection to New Relic in a monitored Resque
  master process failed, the agent would not retry, and monitoring for the
  process would be lost. This has been fixed, and the agent will continue
  retrying in its background harvest thread until it successfully connects.

## v3.15.2 ##

  * Run explain plans on parameterized slow queries in AR4

  In our ActiveRecord 4 instrumentation, we moved to tracing slow queries
  using the payloads from ActiveSupport::Notifications `sql.active_record`
  events. As a result, we were unable to run explain plans on parameterized
  queries. This has now been updated to pass along and use the parameter values,
  when available, to get the explain plans.

  * Fix getMore metric grouping issue in Mongo 2.2.x instrumentation

  A metric grouping issue had cropped up when using the most recent Mongo gem
  (2.2.0) with the most recent release of the server (3.2.4). We now have a more
  future-proof setup for preventing these.

  * Restore older DataMapper support after password obfuscation fix

  Back in 3.14.3, we released a fix to avoid inadvertently sending sensitive
  information from DataMapper SQLErrors. Our implementation did not account for
  DataMapper versions below v0.10.0 not implementing the #options accessor.
  Thanks Bram de Vries for the fix to our fix!

  * Padrino 0.13.1 Support

  Users with Padrino 0.13.x apps were previously seeing the default transaction
  name "(unknown)" for all of their routes. We now provide the full Padrino
  route template in transaction names, including any parameter placeholders.
  Thanks Robert Schulze for the contribution!

  * Update transaction naming for Grape 0.16.x

  In Grape 0.16.x, `route_` methods are no longer prefixed. Thanks to Daniel
  Doubrovkine for the contribution!

  * Fix name collision on method created for default metric name fix

  We had a name collision with the yard gem, which sets a `class_name` method
  on Module. We've renamed our internal method to `derived_class_name` instead.

## v3.15.1 ##

  * Rack 2 alpha support

  This release includes experimental support for Rack 2 as of 2.0.0.alpha.
  Rack 2 is still in development, but the agent should work as expected for
  those who are experimenting with Rack 2.

  * Rails 5 beta 3 support

  We've tweaked our Action View instrumentation to accommodate changes introduced
  in Rails v5.0.0.beta3.

  * Defer referencing ::ActiveRecord::Base to avoid triggering its autoloading
  too soon

  In 3.12.1 and later versions of the agent, the agent references (and
  therefore loads) ActiveRecord::Base earlier on in the Rails loading process.
  This could jump ahead of initializers that should be run first. We now wait
  until ActiveRecord::Base is loaded elsewhere.

  * Fix explain plans for non-parameterized queries with single quote literals

  The agent does not run explain plans for queries still containing parameters
  (such as `SELECT * FROM UNICORNS WHERE ID = $1 LIMIT 1`). This check was
  unfortunately mutating the query to be obfuscated, causing an inability to
  collect an explain plan. This has now been fixed.

  * Fix default metric name for tracing class methods

  When using `add_method_tracer` on a class method but without passing in a
  `metric_name_code`, the default metric name will now look like
  `Custom/ClassName/Class/method_name`. We also addressed default
  metric names for anonymous classes and modules.

  * Fix issue when rendering SQL strings in developer mode

  When we obfuscate SQL statements, we rewrite the Statement objects as
  SQL strings inline in our sample buffers at harvest time. However, in
  developer mode, we also read out of these buffers when rendering pages.
  Depending on whether a harvest has run yet, the buffer will contain either
  Statement objects, SQL strings, or a mix. Now, developer mode can handle
  them all!

  * Fix DelayedJob Sampler reporting incorrect counts in Active Record 3 and below

  When fixing various deprecation warnings on ActiveRecord 4, we introduced
  a regression in our DelayedJob sampler which caused us to incorrectly report
  failed and locked job counts in ActiveRecord 3 and below. This is now fixed.
  Thanks Rangel Dokov for the contribution!

## v3.15.0 ##

  * Rails 5 support

  This release includes experimental support for Rails 5 as of 5.0.0.beta2.
  Please note that this release does not include any support for ActionCable,
  the WebSockets framework new to Rails 5.

  * Don't include extension from single format Grape API transaction names

  Starting with Grape 0.12.0, an API with a single format no longer declares
  methods with `.:format`, but with an extension such as `.json`. Thanks Daniel
  Doubrovkine for the contribution!

  * Fix warnings about shadowing outer local variable when running tests

  Thanks Rafael Almeida de Carvalho for the contribution!

  * Check config first for Rails middleware instrumentation installation

  Checking the config first avoids issues with mock classes that don't implement
  `VERSION`. Thanks Jesse Sanford for the contribution!

  * Remove a trailing whitespace in the template for generated newrelic.yml

  Thanks Paul Menzel for the contribution!

  * Reference external resources in comments and readme with HTTPS

  Thanks Benjamin Quorning for the contribution!

## v3.14.3 ##

  * Don't inadvertently send sensitive information from DataMapper SQLErrors

  DataObjects::SQLError captures the SQL query, and when using versions of
  data_objects prior to 0.10.8, built a URI attribute that contained the
  database connection password. The :query attribute now respects the obfuscation
  level set for slow SQL traces and splices out any password parameters to the
  URI when sending up traced errors to New Relic.

  * Improved SQL obfuscation algorithm

  To help standardize SQL obfuscation across New Relic language agents, we've
  improved the algorithm used and added more test cases.

  * Configurable longer sql_id attribute on slow SQL traces

  The sql_id attribute on slow SQL traces is used to aggregate normalized
  queries together. Previously, these IDs would generally be 9-10 digits long,
  due to a backend restriction. If `slow_sql.use_longer_sql_id` is set to `true`,
  these IDs will now be 18-19 digits long.

## v3.14.2 ##

  * Improved transaction names for Sinatra

  The agent will now use sinatra.route for transaction names on Sinatra 1.4.3+,
  which sets it in the request environment. This gives names that closer resemble the
  routes defined in the Sinatra DSL.  Thanks to Brian Phillips for the suggestion!

  * Bugfix for error flag on transaction events

  There was an issue causing the error flag to always be set to false for Insights
  transaction events that has been fixed.

  * Official support for Sidekiq 4

  The Ruby agent now officially supports Sidekiq 4.

  * Additional attributes collected

  The agent now collects the following information in web transactions:
  Content-Length HTTP response and Content-Type HTTP request headers.

## v3.14.1 ##

  * Add support for setting a display name on hosts

  You can now configure a display name for your hosts using process_host.display_name,
  to more easily distinguish dynamically assigned hosts. For more info, see
  https://docs.newrelic.com/docs/apm/new-relic-apm/maintenance/add-rename-remove-hosts#display_name

  * Fixes automatic middleware instrumentation for Puma 2.12.x

  Starting with version 2.12.x the Puma project inlines versions of Rack::Builder
  and Rack::URLMap under the Puma namespace. This had the unfortunate side effect of
  breaking automatic Rack middleware instrumentation. We now instrument Puma::Rack::Builder
  and Puma::Rack::URLMap and once again have automatic Rack middleware instrumentation for
  applications running on Puma.

  * Do not use a DelayedJob's display_name for naming the transaction

  A DelayedJob's name may be superceded by a display_name, which can
  lead to a metric grouping issue if the display_name contains unique
  identifiers. We no longer use job name methods that may lead to an
  arbitrary display_name. Instead, we use the appropriate class and/or
  method names, depending what makes sense for the job and how it's called.

  * Improvements to Mongo 2.1.x instrumentation

  Fixes issue where getMore operations in batched queries could create metric grouping issues.
  Previously when multiple Mongo queries executed in the same scope only a single query was recorded
  as part of a transaction trace. Now transaction trace nodes will be created for every query
  executed during a transaction.

  * Bugfix for NewRelic::Agent.notice_error

  Fixes issue introduced in v3.14.0 where calling NewRelic::Agent.notice_error outside of an active
  transaction results in a NoMethodError.

  * Bugfix for Resque TransactionError events

  Fixes error preventing Transaction Error events generated in Resque tasks from being sent to New Relic.

## v3.14.0 ##

  * pruby marshaller removed

  The deprecated pruby marshaller has now been removed; the `marshaller` config
  option now only accepts `json`. Customers still running Ruby 1.8.7/REE must
  add the `json` gem to their Gemfile, or (preferably) upgrade to Ruby 1.9.3 or
  newer.

  * Log dates in ISO 8601 format

  The agent will now log dates in ISO 8601 (YYYY-mm-dd) format, instead of
  mm/dd/yy.

  * Additional attributes collected

  The agent now collects the following information in web transactions:
  Accept, Host, User-Agent, Content-Length HTTP request headers, HTTP request
  method, and Content-Type HTTP response header.

  * TransactionErrors reported for Advanced Analytics for APM Errors

  With this release, the agent reports TransactionError events. These new events
  power the beta feature Advanced Analytics for APM Errors. The error events are
  also available today through New Relic Insights.

  Advanced Analytics for APM Errors lets you see all of your errors, with
  granular detail. Filter and group by any attribute to analyze them. Take
  action to resolve issues through collaboration.

  For more information, see https://docs.newrelic.com/docs/apm/applications-menu/events/view-apm-errors-error-traces

## v3.13.2 ##

  * Don't fail to send data when using 'mathn' library

  Version 3.12.1 introduced a bug with applications using the 'mathn' library
  that would prevent the agent from sending data to New Relic. This has been
  fixed.

## v3.13.1 ##

  * Don't use a pager when running `git log` command

  This would cause Capistrano deploys to hang when a large number of commits were being deployed.
  Thanks to John Naegle for reporting and fixing this issue!

  * Official support for JRuby 9.0.0.0

  The Ruby agent is now officially fully tested and supported on JRuby 9.0.0.0.

  * Instrumentation for MongoDB 2.1.x

  Visibility in your MongoDB queries returns when using version 2.1.0 of
  the Mongo driver or newer.  Thanks to Durran Jordan of MongoDB for contributing
  the Mongo Monitoring instrumentation!

  * Fix for ArgumentError "invalid byte sequence in UTF-8"

  This would come up when trying to parse out the operation from a database query
  containing characters that would trigger a invalid byte sequence in UTF-8 error.
  Thanks to Mario Izquierdo for reporting this issue!

  * Improved database metric names for ActiveRecord::Calculations queries

  Aggregate metrics recorded for queries made via the ActiveRecord::Calculations
  module (#count, #sum, #max, etc.) will now be associated with the correct
  model name, rather than being counted as generic 'select' operations.

  * Allow at_exit handlers to be installed for Rubinius

  Rubinius can support the at_exit block used by install_exit_handler.
  Thanks to Aidan Coyle for reporting and fixing this issue!

## v3.13.0 ##

  * Bugfix for uninitialized constant NewRelic::Agent::ParameterFiltering

  Users in some environments encountered a NameError: uninitialized constant
  NewRelic::Agent::ParameterFiltering from the Rails instrumentation while
  running v3.12.x of the Ruby agent. This issue has been fixed.

  * Rake task instrumentation

  The Ruby agent now provides opt-in tracing for Rake tasks. If you run
  long jobs via Rake, you can get all the visibility and goodness of New Relic
  that your other background jobs have. To enable this, see
  https://docs.newrelic.com/docs/agents/ruby-agent/frameworks/rake

  * Redis instrumentation

  Redis operations will now show up on the Databases tab and in transaction
  traces. By default, only command names will be captured; to capture command
  arguments, set `transaction_tracer.record_redis_arguments` to `true` in
  your configuration.

  * Fix for over-obfuscated SQL Traces and PostgreSQL

  An issue with the agent obfuscating column and table names from Slow SQL
  Traces when using PostgreSQL has been resolved.

  * Rubinius 2.5.8 VM metric renaming support

  Rubinius 2.5.8 changed some VM metric names and eliminated support for
  total allocated object counters. The agent has been updated accordingly.

  * Fix agent attributes with a value of false not being stored

  An issue introduced in v3.12.1 prevented attributes (like those added with
  `add_custom_attributes`) from being stored if their value was false. This has
  been fixed.

## v3.12.1 ##

  * More granular Database metrics for ActiveRecord 3 and 4

  Database metrics recorded for non-SELECT operations (UPDATE, INSERT, DELETE,
  etc.) on ActiveRecord 3 and 4 now include the model name that the query was
  being executed against, allowing you to view these queries broken down by
  model on the Datastores page. Thanks to Bill Kayser for reporting this issue!

  * Support for Multiverse testing third party gems

  The Ruby agent has rich support for testing multiple gem versions, but
  previously that wasn't accessible to third party gems.  Now you can now
  simply `require 'task/multiverse'` in your Rakefile to access the same
  test:multiverse task that New Relic uses itself. For more details, see:

  https://docs.newrelic.com/docs/agents/ruby-agent/frameworks/third-party-instrumentation#testing-your-extension

  * Use Sidekiq 3.x's error handler

  Sidekiq 3.x+ provides an error handler for internal and middleware related
  failures. Failures at these points were previously unseen by the Ruby agent,
  but now they are properly traced.

  * Better error messages for common configuration problems with Capistrano

  Templating errors in newrelic.yml would result in obscure error messages
  during Capistrano deployments. These messages now more properly reflect the
  root cause of the errors.

  * newrelic_ignore methods allow strings

  The newrelic_ignore methods previously only supported passing symbols, and
  would quietly ignore any strings passed. Now strings can be passed as well
  to get the intuitive ignoring behavior you'd expect.

  * Replace DNS resolver for Resque jobs with Resolv

  In some circumstances customers with a very high number of short-lived Resque
  jobs were experiencing deadlocks during DNS resolution. Resolv is an all Ruby
  DNS resolver that replaces the libc implementation to prevent these deadlocks.

## v3.12.0 ##

  * Flexible capturing of attributes

  The Ruby agent now allows you more control over exactly which request
  parameters and job arguments are attached to transaction traces, traced
  errors, and Insights events. For details, see:

  https://docs.newrelic.com/docs/agents/ruby-agent/ruby-agent-attributes

  * Fixed missing URIs in traces for retried Excon requests

  If Excon's idempotent option retried a request, the transaction trace node
  for the call would miss having the URI assigned. This has been fixed.

  * Capturing request parameters from rescued exceptions in Grape

  If an exception was handled via a rescue_from in Grape, request parameters
  were not properly set on the error trace. This has been fixed. Thanks to
  Ankit Shah for helping us spot the bug.

## v3.11.2 ##

  * Better naming for Rack::URLMap

  If a Rack app made direct use of Rack::URLMap, instrumentation would miss
  out on using the clearest naming based on the app class. This has been
  fixed.

  * Avoid performance regression in makara database adapter

  Delegation in the makara database adapter caused performance issues when the
  agent looked up a connection in the pool.  The agent now uses a faster
  lookup to work around this problem in makara, and allocates less as well.
  Thanks Mike Nelson for the help in resolving this!

  * Allow audit logging to STDOUT

  Previously audit logs of the agent's communication with New Relic could only
  write to a file. This prevented using the feature on cloud providers like
  Heroku. Now STDOUT is an allowed destination for `audit_log.path`. Logging
  can also be restricted to certain endpoints via `audit_log.endpoints`.

  For more information see https://docs.newrelic.com/docs/agents/ruby-agent/installation-configuration/ruby-agent-configuration#audit_log

  * Fix for crash during startup when Rails required but not used

  If an application requires Rails but wasn't actually running it, the Ruby
  agent would fail during startup. This has been fixed.

  * Use IO.select explicitly in the event loop

  If an application adds their own select method to Object/Kernel or mixes in a
  module that overrides the select method (as with ActionView::Helpers) we would
  previously have used their implementation instead of the intended IO.select,
  leading to all sorts of unusual errors. We now explicitly reference IO.select
  in the event loop to avoid these issues.

  * Fix for background thread hangs on old Linux kernels

  When running under Ruby 1.8.7 on Linux kernel versions 2.6.11 and earlier,
  the background thread used by the agent to report data would hang, leading
  to no data being reported. This has been be fixed.

## v3.11.1 ##

  If an application adds their own select method to Object/Kernel or mixes in a
  module that overrides the select method (as with ActionView::Helpers) we would
  previously have used their implementation instead of the intended IO.select,
  leading to all sorts of unusual errors. We now explicitly reference IO.select
  in the event loop to avoid these issues.

  * Fix for background thread hangs on old Linux kernels

  When running under Ruby 1.8.7 on Linux kernel versions 2.6.11 and earlier,
  the background thread used by the agent to report data would hang, leading
  to no data being reported. This has been be fixed.

## v3.11.1 ##

  The Ruby agent incorrectly rescued exceptions at a point which caused
  sequel_pg 1.6.11 to segfault. This has been fixed. Thanks to Oldrich
  Vetesnik for the report!

## v3.11.0 ##

  * Unified view for SQL database and NoSQL datastore products.

  The response time charts in the application overview page will now include
  NoSQL datastores, such as MongoDB, and also the product name of existing SQL
  databases such as MySQL, Postgres, etc.

  The Databases page will now enable the filtering of metrics and operations
  by product, and includes a table listing all operations.

  For existing SQL databases, in addition to the existing breakdown of SQL
  statements and operations, the queries are now also associated with the
  database product being used.

  For NoSQL datastores, such as MongoDB, we have now added information about
  operations performed against those products, similar to what is being done
  for SQL databases.

  Because this introduces a notable change to how SQL database metrics are
  collected, it is important that you upgrade the agent version on all hosts.
  If you are unable to transition to the latest agent version on all hosts at
  the same time, you can still access old and new metric data for SQL
  databases, but the information will be split across two separate views.

  For more information see https://docs.newrelic.com/docs/apm/applications-menu/monitoring/databases-slow-queries-dashboard

  * Track background transactions as Key Transactions

  In prior versions of the Ruby agent, only web transactions could be tracked
  as Key Transactions. This functionality is now available to all
  transactions, including custom Apdex values and X-Ray sessions.

  For more information see https://docs.newrelic.com/docs/apm/selected-transactions/key-transactions/key-transactions-tracking-important-transactions-or-events

  * More support and documentation for third-party extensions

  It's always been possible to write extension gems for the Ruby agent, but
  now there's one location with best practices and recommendations to guide
  you in writing extensions. Check out
  https://docs.newrelic.com/docs/agents/ruby-agent/frameworks/third-party-instrumentation

  We've also added simpler APIs for tracing datastores and testing your
  extensions. It's our way of giving back to everyone who's helped build on
  the agent over the years. <3

  * Fix for anonymous class middleware naming

  Metric names based off anonymous middlewares lacked a class name in the UI.
  The Ruby agent will now look for a superclass, or default to AnonymousClass
  in those cases.

  * Improved exit behavior in the presence of Sinatra

  The agent uses an `at_exit` hook to ensure data from the last < 60s before a
  process exits is sent to New Relic. Previously, this hook was skipped if
  Sinatra::Application was defined. This unfortunately missed data for
  short-lived background processes that required, but didn't run, Sinatra. Now
  the agent only skips its `at_exit` hook if Sinatra actually runs from
  `at_exit`.

## v3.10.0 ##

  * Support for the Grape framework

  We now instrument the Grape REST API framework! To avoid conflicts with the
  third-party newrelic-grape gem, our instrumentation will not be installed if
  newrelic-grape is present in the Gemfile.

  For more details, see https://docs.newrelic.com/docs/agents/ruby-agent/frameworks/grape-instrumentation

  * Automatic Cross Application Tracing support for all Rack applications

  Previously Rack apps not using Rails or Sinatra needed to include the
  AgentHooks middleware to get Cross Application Tracing support. With
  these changes, this is no longer necessary. Any explicit references to
  AgentHooks can be removed unless the `disable_middleware_instrumentation`
  setting is set to `true`.

  * Metrics no longer reported from Puma master processes

  When using Puma's cluster mode with the preload_app! configuration directive,
  the agent will no longer start its reporting thread in the Puma master
  process. This should result in more accurate instance counts, and more
  accurate stats on the Ruby VMs page (since the master process will be
  excluded).

  * Better support for Sinatra apps used with Rack::Cascade

  Previously, using a Sinatra application as part of a Rack::Cascade chain would
  cause all transactions to be named after the Sinatra application, rather than
  allowing downstream applications to set the transaction name when the Sinatra
  application returned a 404 response. This has been fixed.

  * Updated support for Rubinius 2.3+ metrics

  Rubinius 2.3 introduced a new system for gathering metrics from the
  underlying VM. Data capture for the Ruby VM's page has been updated to take
  advantage of these. Thanks Yorick Peterse for the contribution!

  * Fix for missing ActiveJob traced errors

  ActiveJobs processed by backends where the Ruby agent lacked existing
  instrumentation missed reporting traced errors. This did not impact
  ActiveJobs used with Sidekiq or Resque, and has been fixed.

  * Fix possible crash in middleware tracing

  In rare circumstances, a failure in the agent early during tracing of a web
  request could lead to a cascading error when trying to capture the HTTP status
  code of the request. This has been fixed. Thanks to Michal Cichra for the fix!

## v3.9.9 ##

  * Support for Ruby 2.2

  A new version of Ruby is available, and the Ruby agent is ready to run on
  it. We've been testing things out since the early previews so you can
  upgrade to the latest and greatest and use New Relic right away to see how
  the new Ruby's performing for you.

  * Support for Rails 4.2 and ActiveJob

  Not only is a new Ruby available, but a new Rails is out too! The Ruby agent
  provides all the usual support for Rails that you'd expect, and we
  instrument the newly released ActiveJob framework that's part of 4.2.

  * Security fix for handling of error responses from New Relic servers

  This release fixes a potential security issue wherein an attacker who was able
  to impersonate New Relic's servers could have triggered arbitrary code
  execution in agent's host processes by sending a specially-crafted error
  response to a data submission request.

  This issue is mitigated by the fact that the agent uses SSL certificate
  checking in order to verify the identity of the New Relic servers to which it
  connects. SSL is enabled by default by the agent, and can be enforced
  account-wide by enabling High Security Mode for your account:

  https://docs.newrelic.com/docs/accounts-partnerships/accounts/security/high-security

  * Fix for transactions with invalid URIs

  If an application used the agent's `ignore_url_regexes` config setting to
  ignore certain transactions, but received an invalid URI, the agent would
  fail to record the transaction. This has been fixed.

  * Fixed incompatibility with newrelic-grape

  The 3.9.8 release of the Ruby agent included disabled prototyped
  instrumentation for the Grape API framework. This introduced an
  incompatibility with the existing third party extension newrelic-grape. This
  has been fixed. Newrelic-grape continues to be the right solution until
  full agent support for Grape is available.

## v3.9.8 ##

  * Custom Insights events API

  In addition to attaching custom parameters to the events that the Ruby agent
  generates automatically for each transaction, you can now record custom event
  types into Insights with the new NewRelic::Agent.record_custom_event API.

  For details, see https://docs.newrelic.com/docs/insights/new-relic-insights/adding-querying-data/inserting-custom-events-new-relic-agents

  * Reduced memory usage for idling applications

  Idling applications using the agent could previously appear to leak memory
  because of native allocations during creation of new SSL connections to our
  servers. These native allocations didn't factor into triggering Ruby's
  garbage collector.

  The agent will now re-use a single TCP connection to our servers for as long
  as possible, resulting in improved memory usage for applications that are
  idling and not having GC triggered for other reasons.

  * Don't write to stderr during CPU sampling

  The Ruby agent's code for gathering CPU information would write error
  messages to stderr on some FreeBSD systems. This has been fixed.

  * LocalJumpError on Rails 2.x

  Under certain conditions, Rails 2.x controller instrumentation could fail
  with a LocalJumpError when an action was not being traced. This has been
  fixed.

  * Fixed config lookup in warbler packaged apps

  When running a Ruby application from a standalone warbler .jar file on
  JRuby, the packaged config/newrelic.yml was not properly found. This has
  been fixed, and thanks to Bob Beaty for the help getting it fixed!

  * Hash iteration failure in middleware

  If a background thread iterated over the keys in the Rack env hash, it could
  cause failures in New Relic's AgentHooks middleware. This has been fixed.

## v3.9.7 ##

  * Support for New Relic Synthetics

  The Ruby agent now gives you additional information for requests from New
  Relic Synthetics. More transaction traces and events give you a clearer look
  into how your application is performing around the world.

  For more details, see https://docs.newrelic.com/docs/synthetics/new-relic-synthetics/getting-started/new-relic-synthetics

  * Support for multiple job per fork gems with Resque

  The resque-jobs-per-fork and resque-multi-job-forks gems alter Resque to
  fork every N jobs instead of every job. This previously caused issues for
  the Ruby agent, but those have been resolved. These gems are fully supported.

  Running Resque with the FORK_PER_JOB=false environment variable setting is
  also supported now.

  For more details on our Resque support, see https://docs.newrelic.com/docs/agents/ruby-agent/background-jobs/resque-instrumentation

  * Support agent when starting Resque Pool from Rake task

  When running resque-pool with its provided rake tasks, the agent would not
  start up properly. Thanks Tiago Sousa for the fix!

  * Fix for DelayedJob + Rails 4.x queue depth metrics

  The Ruby agent periodically records DelayedJob queuedepth as a metric, but
  this didn't work properly in Rails 4.x applications.  This has been fixed.
  Thanks Jonathan del Strother for his help with the issue!

  * Fix for failure in background transactions with rules.ignore_url_regexes

  The recently added feature for ignoring transactions via URL regexes caused
  errors for non-web transactions. This has been fixed.

  * Rename the TransactionNamer.name method to TransactionNamer.name_for

  The internal TransactionNamer class had a class method called 'name', with a
  different signature than the existing Class#name method and could cause
  problems when trying to introspect instances of the class.

  Thanks to Dennis Taylor for contributing this fix!

## v3.9.6 ##

  * Rails 4.2 ActiveJob support

  A new version of Rails is coming! One of the highlight features is
  ActiveJob, a framework for interacting with background job processors. This
  release of the Ruby agent adds instrumentation to give you insight into
  ActiveJob, whether you're just testing it out or running it for real.

  Metrics are recorded around enqueuing ActiveJobs, and background transactions
  are started for any ActiveJob performed where the agent didn't already
  provide specific instrumentation (such as DelayedJob, Resque and Sidekiq).

  Since Rails 4.2 is still in beta we'd love to hear any feedback on this
  instrumentation so it'll be rock solid for the general release!

  * Ruby 2.2.0-preview1 updates

  Ruby 2.2.0 is on its way later in the year, and the Ruby agent is ready for
  it. Updates to the GC stats and various other small changes have already been
  applied, and our automated tests are running against 2.2.0 so the agent will
  be ready on release day.

  * Ignoring transactions by URL

  While you could always ignore transactions by controller and action, the
  Ruby agent previously lacked a way to ignore by specific URLs or patterns
  without code changes. This release adds the config setting,
  `rules.ignore_url_regexes` to ignore specific transactions based on the
  request URL as well. For more information, see the documentation at:
  https://docs.newrelic.com/docs/agents/ruby-agent/installation-configuration/ignoring-specific-transactions#config-ignoring

  * Better dependency detection in non-Rack applications

  The Ruby agent runs dependency detection at key points in the Rack and Rails
  lifecycle, but non-Rails apps could occasionally miss out instrumenting late
  loaded libraries. The agent now runs an additional dependency detection
  during manual_start to more seamlessly install instrumentation in any app.

  * Excluding /newrelic routes from developer mode

  Recent changes to track time in middleware resulted in New Relic's developer
  mode capturing its own page views in the list. This has been fixed. Thanks
  to Ignatius Reza Lesmana for the report!

  * Spikes in external time

  Timeouts during certain external HTTP requests could result in incorrect
  large spikes in the time recorded by the agent. This has been fixed.

  * Recognize browser_monitoring.auto_instrument setting in non-Rails apps

  The `browser_monitoring.auto_instrument` config setting disables
  auto-injection of JavaScript into your pages, but was not properly obeyed in
  Sinatra and other non-Rails contexts.  This has been fixed.

  * Failures to gather CPU thread time on JRuby

  JRuby running on certain JVM's and operating systems (FreeBSD in particular)
  did not always support the method being used to gather CPU burn metrics.
  This would result in a failure during those transactions. This has been
  fixed.

  * Fix for rare race condition in Resque instrumentation

  A race condition in the agent's Resque instrumentation that could cause rare
  Resque job failures in high-throughput Resque setups has been fixed. This bug
  would manifest as an exception with the following error message:
  "RuntimeError: can't add a new key into hash during iteration" and a backtrace
  leading through the PipeChannelManager class in the agent.

## v3.9.5 ##

  * Per-dyno data on Heroku

  When running on Heroku, data from the agent can now be broken out by dyno
  name, allowing you to more easily see what's happening on a per-dyno level.
  Dynos on Heroku are now treated in the same way that distinct hosts on other
  platforms work.

  By default, 'scheduler' and 'run' dyno names will be aggregated into
  'scheduler.*' and 'run.*' to avoid unbounded growth in the number of reported
  hostnames.

  Read more about this feature on our Heroku docs page:
  https://docs.newrelic.com/docs/agents/ruby-agent/miscellaneous/ruby-agent-heroku

  * HTTP response codes in Insights events

  The Ruby agent will now capture HTTP response codes from Rack applications
  (including Rails and Sinatra apps) and include them under the httpResponseCode
  attribute on events sent to Insights.

  * Stricter limits on memory usage of SQL traces

  The agent now imposes stricter limits on the number of distinct SQL traces
  that it will buffer in memory at any point in time, leading to more
  predictable memory consumption even in exceptional circumstances.

  * Improved reliability of thread profiling

  Several issues that would previously have prevented the successful completion
  and transmission of thread profiles to New Relic's servers have been fixed.

  These issues were related to the use of recursion in processing thread
  profiles, and have been addressed by both limiting the maximum depth of the
  backtraces recorded in thread profiles, and eliminating the agent's use of
  recursion in processing profile data.

  * Allow tracing Rails view helpers with add_method_tracer

  Previously, attempting to trace a Rails view helper method using
  add_method_tracer on the view helper module would lead to a NoMethodError
  when the traced method was called (undefined method `trace_execution_scoped').
  This has been fixed.

  This issue was an instance of the Ruby 'dynamic module inclusion' or 'double
  inclusion' problem. Usage of add_method_tracer now no longer relies upon the
  target class having actually picked up the trace_execution_scoped method from
  the NewRelic::Agent::MethodTracer module.

  * Improved performance of queue time parsing

  The number of objects allocated while parsing the front-end timestamps on
  incoming HTTP requests has been significantly reduced.

  Thanks to Aleksei Magusev for the contribution!

## v3.9.4 ##

  * Allow agent to use alternate certificate stores

  When connecting via SSL to New Relic services, the Ruby agent verifies its
  connection via a certificate bundle shipped with the agent. This had problems
  with certain proxy configurations, so the `ca_bundle_path` setting in
  newrelic.yml can now override where the agent locates the cert bundle to use.

  For more information see the documentation at:
  https://docs.newrelic.com/docs/agents/ruby-agent/installation-configuration/ssl-settings-ruby-agent

  * Rails 4.2 beta in tests

  Although still in beta, a new version of Rails is on its way!  We're
  already running our automated test suites against the beta to ensure New
  Relic is ready the day the next Rails is released.

  * ActiveRecord 4 cached queries fix

  Queries that were hitting in the ActiveRecord 4.x query cache were
  incorrectly being counted as database time by the agent.

  * Fix for error in newrelic.yml loading

  If your application ran with a RAILS_ENV that was not listed in newrelic.yml
  recent agent versions would give a NameError rather than a helpful message.
  This has been fixed. Thanks Oleksiy Kovyrin for the patch!

## v3.9.3 ##

  * Fix to prevent proxy credentials transmission

  This update prevents proxy credentials set in the agent config file from
  being transmitted to New Relic.

## v3.9.2 ##

  * Added API for ignoring transactions

  This release adds three new API calls for ignoring transactions:

    - `NewRelic::Agent.ignore_transaction`
    - `NewRelic::Agent.ignore_apdex`
    - `NewRelic::Agent.ignore_enduser`

  The first of these ignores a transaction completely: nothing about it will be
  reported to New Relic. The second ignores only the Apdex metric for a single
  transaction. The third disables javascript injection for browser monitoring
  for the current transaction.

  These methods differ from the existing newrelic_ignore_* method in that they
  may be called *during* a transaction based on some dynamic runtime criteria,
  as opposed to at the class level on startup.

  See the docs for more details on how to use these methods:
  https://docs.newrelic.com/docs/agents/ruby-agent/installation-and-configuration/ignoring-specific-transactions

  * Improved SQL obfuscation

  SQL queries containing string literals ending in backslash ('\') characters
  would previously not have been obfuscated correctly by the Ruby agent prior to
  transmission to New Relic. In addition, SQL comments were left un-obfuscated.
  This has been fixed, and the test coverage for SQL obfuscation has been
  improved.

  * newrelic_ignore* methods now work when called in a superclass

  The newrelic_ignore* family of methods previously did not apply to subclasses
  of the class from which it was called, meaning that Rails controllers
  inheriting from a single base class where newrelic_ignore had been called
  would not be ignored. This has been fixed.

  * Fix for rare crashes in Rack::Request#params on Sinatra apps

  Certain kinds of malformed HTTP requests could previously have caused
  unhandled exceptions in the Ruby agent's Sinatra instrumentation, in the
  Rack::Request#params method. This has been fixed.

  * Improved handling for rare errors caused by timeouts in Excon requests

  In some rare cases, the agent would emit a warning message in its log file and
  abort instrumentation of a transaction if a timeout occurred during an
  Excon request initiated from within that transaction. This has been fixed.

  * Improved behavior when the agent is misconfigured

  When the agent is misconfigured by attempting to shut it down without
  it ever having been started, or by attempting to disable instrumentation after
  instrumentation has already been installed, the agent will no longer raise an
  exception, but will instead log an error to its log file.

  * Fix for ignore_error_filter not working in some configurations

  The ignore_error_filter method allows you to specify a block to be evaluated
  in order to determine whether a given error should be ignored by the agent.
  If the agent was initially disabled, and then later enabled with a call to
  manual_start, the ignore_error_filter would not work. This has been fixed.

  * Fix for Capistrano 3 ignoring newrelic_revision

  New Relic's Capistrano recipes support passing parameters to control the
  values recorded with deployments, but user provided :newrelic_revision was
  incorrectly overwritten. This has been fixed.

  * Agent errors logged with ruby-prof in production

  If the ruby-prof gem was available in an environment without New Relic's
  developer mode enabled, the agent would generate errors to its log. This has
  been fixed.

  * Tighter requirements on naming for configuration environment variables

  The agent would previously assume any environment variable containing
  'NEWRELIC' was a configuration setting. It now looks for this string as a
  prefix only.

  Thanks to Chad Woolley for the contribution!

## v3.9.1 ##

  * Ruby 1.8.7 users: upgrade or add JSON gem now

  Ruby 1.8.7 is end-of-lifed, and not receiving security updates, so we strongly
  encourage all users with apps on 1.8.7 to upgrade.

  If you're not able to upgrade yet, be aware that a coming release of the Ruby
  agent will require users of Ruby 1.8.7 to have the 'json' gem available within
  their applications in order to continue sending data to New Relic.

  For more details, see:
  https://docs.newrelic.com/docs/ruby/ruby-1.8.7-support

  * Support for new Cross Application Trace view

  This release enhances cross application tracing with a visualization of
  the cross application calls that a specific Transaction Trace is involved
  in. The new visualization helps you spot bottlenecks in external services
  within Transaction Traces and gives you an end-to-end understanding
  of how the transaction trace is used by other applications and services.
  This leads to faster problem diagnosis and better collaboration across
  teams. All agents involved in the cross application communication must
  be upgraded to see the complete graph. You can view cross application
  traces from in the Transaction Trace drill-down.

  * High security mode V2

  The Ruby agent now supports V2 of New Relic's high security mode. To enable
  it, you must add 'high_security: true' to your newrelic.yml file, *and* enable
  high security mode through the New Relic web interface. The local agent
  setting must be in agreement with the server-side setting, or the agent will
  shut down and no data will be collected.

  Customers who already had the server-side high security mode setting enabled
  must add 'high_security: true' to their agent configuration files when
  upgrading to this release.

  For details on high security mode, see:
  http://docs.newrelic.com/docs/accounts-partnerships/accounts/security/high-security

  * Improved memcached instrumentation

  More accurate instrumentation for the 'cas' command when using version 1.8.0
  or later of the memcached gem. Previous versions of the agent would count all
  time spent in the block given to 'cas' as memcache time, but 1.8.0 and later
  allows us to more accurately measure just the time spent talking to memcache.

  Many thanks to Francis Bogsanyi for contributing this change!

  * Improved support for Rails apps launched from outside the app root directory

  The Ruby agent attempts to resolve the location of its configuration file at
  runtime relative to the directory that the host process is started from.

  In cases where the host process was started from outside of the application's
  root directory (for example, if the process is started from from '/'), it will
  now also attempt to locate its configuration file based on the value of
  Rails.root for Rails applications.

  * Better compatibility with ActionController::Live

  Browser Application Monitoring auto-injection can cause request failures under
  certain circumstances when used with ActionController::Live, so the agent will
  now automatically detect usage of ActionController::Live, and not attempt
  auto-injection for those requests (even if auto-instrumentation is otherwise
  enabled).

  Many thanks to Rodrigo Rosenfeld Rosas for help diagnosing this issue!

  * Fix for occasional spikes in external services time

  Certain kinds of failures during HTTP requests made by an application could
  have previously resulted in the Ruby agent reporting erroneously large amounts
  of time spent in outgoing HTTP requests. This issue manifested most obviously
  in spikes on the 'Web external' band on the main overview graph. This issue
  has now been fixed.

  * Fix 'rake newrelic:install' for Rails 4 applications

  The newrelic:install rake task was previously not working for Rails 4
  applications and has been fixed.

  Thanks to Murahashi Sanemat Kenichi for contributing this fix!

## v3.9.0 ##

  * Rack middleware instrumentation

  The Ruby agent now automatically instruments Rack middlewares!

  This means that the agent can now give you a more complete picture of your
  application's response time, including time spent in middleware. It also means
  that requests which previously weren't captured by the agent because they
  never made it to the bottom of your middleware stack (usually a Rails or
  Sinatra application) will now be captured.

  After installing this version of the Ruby agent, you'll see a new 'Middleware'
  band on your application's overview graph, and individual middlewares will
  appear in transaction breakdown charts and transaction traces.

  The agent can instrument middlewares that are added from a config.ru file via
  Rack::Builder, or via Rails' middleware stack in Rails 3.0+.

  This instrumentation may be disabled with the
  disable_middlware_instrumentation configuration setting.

  For more details, see the documentation for this feature:

    - http://docs.newrelic.com/docs/ruby/rack-middlewares
    - http://docs.newrelic.com/docs/ruby/middleware-upgrade-changes

  * Capistrano 3.x support

  Recording application deployments using Capistrano 3.x is now supported.

  Many thanks to Jennifer Page for the contribution!

  * Better support for Sidekiq's Delayed extensions

  Sidekiq jobs executed via the Delayed extensions (e.g. the #delay method) will
  now be named after the actual class that #delay was invoked against, and will
  have their job arguments correctly captured if the sidekiq.capture_params
  configuration setting is enabled.

  Many thanks to printercu for the contribution!

  * Improved Apdex calculation with ignored error classes

  Previously, a transaction resulting in an exception that bubbled up to the top
  level would always be counted as failing for the purposes of Apdex
  calculations (unless the transaction name was ignored entirely). Now,
  exceptions whose classes have been ignored by the
  error_collector.ignore_errors configuration setting will not cause a
  transaction to be automatically counted as failing.

  * Allow URIs that are not parseable by stdlib's URI if addressable is present

  There are some URIs that are valid by RFC 3986, but not parseable by Ruby's
  stdlib URI class. The Ruby agent will now attempt to use the addressable gem
  to parse URIs if it is present, allowing requests against these problematic
  URIs to be instrumented.

  Many thanks to Craig R Webster and Amir Yalon for their help with this issue!

  * More robust error collection from Resque processes

  Previously, traced errors where the exception class was defined in the Resque
  worker but not in the Resque master process would not be correctly handled by
  the agent. This has been fixed.

  * Allow Sinatra apps to set the New Relic environment without setting RACK_ENV

  The NEW_RELIC_ENV environment variable may now be used to specify the
  environment the agent should use from its configuration file, independently of
  RACK_ENV.

  Many thanks to Mario Izquierdo for the contribution!

  * Better error handling in Browser Application Monitoring injection

  The agent middleware that injects the JavaScript code necessary for Browser
  Application Monitoring now does a better job of catching errors that might
  occur during the injection process.

  * Allow disabling of Net::HTTP instrumentation

  Most instrumentation in the Ruby agent can be disabled easily via a
  configuration setting. Our Net::HTTP instrumentation was previously an
  exception, but now it can also be disabled with the disable_net_http
  configuration setting.

  * Make Rails constant presence check more defensive

  The Ruby agent now guards against the (rare) case where an application has a
  Rails constant defined, but no Rails::VERSION constant (because Rails is not
  actually present).

  Many thanks to Vladimir Kiselev for the contribution!

## v3.8.1 ##

  * Better handling for Rack applications implemented as middlewares

  When using a Sinatra application as a middleware around another app (for
  example, a Rails app), or manually instrumenting a Rack middleware wrapped
  around another application, the agent would previously generate two separate
  transaction names in the New Relic UI (one for the middleware, and one for
  the inner application).

  As of this release, the agent will instead unify these two parts into a single
  transaction in the UI. The unified name will be the name assigned to the
  inner-most traced transaction by default. Calls to
  NewRelic::Agent.set_transaction_name will continue to override the default
  names assigned by the agent's instrumentation code.

  This change also makes it possible to run X-Ray sessions against transactions
  of the 'inner' application in cases where one instrumented app is wrapped in
  another that's implemented as a middleware.

  * Support for mongo-1.10.0

  The Ruby agent now instruments version 1.10.0 of the mongo gem (versions 1.8.x
  and 1.9.x were already supported, and continue to be).

  * Allow setting configuration file path via an option to manual_start

  Previously, passing the :config_path option to NewRelic::Agent.manual_start
  would not actually affect the location that the agent would use to look for
  its configuration file. This has been fixed, and the log messages emitted when
  a configuration file is not found should now be more helpful.

## v3.8.0 ##

  * Better support for forking and daemonizing dispatchers (e.g. Puma, Unicorn)

  The agent should now work out-of-the box with no special configuration on
  servers that fork or daemonize themselves (such as Unicorn or Puma in some
  configurations). The agent's background thread will be automatically restarted
  after the first transaction processed within each child process.

  This change means it's no longer necessary to set the
  'restart_thread_in_children setting' in your agent configuration file if you
  were doing so previously.

  * Rails 4.1 support

  Rails 4.1 has shipped, and the Ruby agent is ready for it! We've been running
  our test suites against the release candidates with no significant issues, so
  we're happy to announce full compatibility with this new release of Rails.

  * Ruby VM measurements

  The Ruby agent now records more detailed information about the performance and
  behavior of the Ruby VM, mainly focused around Ruby's garbage collector. This
  information is exposed on the new 'Ruby VM' tab in the UI. For details about
  what is recorded, see:

  http://docs.newrelic.com/docs/ruby/ruby-vm-stats

  * Separate in-transaction GC timings for web and background processes

  Previously, an application with GC instrumentation enabled, and both web and
  background processes reporting in to it would show an overly inflated GC band
  on the application overview graph, because data from both web and non-web
  transactions would be included. This has been fixed, and GC time during web
  and non-web transactions is now tracked separately.

  * More accurate GC measurements on multi-threaded web servers

  The agent could previously have reported inaccurate GC times on multi-threaded
  web servers such as Puma. It will now correctly report GC timings in
  multi-threaded contexts.

  * Improved ActiveMerchant instrumentation

  The agent will now trace the store, unstore, and update methods on
  ActiveMerchant gateways. In addition, a bug preventing ActiveMerchant
  instrumentation from working on Ruby 1.9+ has been fixed.

  Thanks to Troex Nevelin for the contribution!

  * More robust Real User Monitoring script injection with charset meta tags

  Previous versions of the agent with Real User Monitoring enabled could have
  injected JavaScript code into the page above a charset meta tag. By the HTML5
  spec, the charset tag must appear in the first 1024 bytes of the page, so the
  Ruby agent will now attempt to inject RUM script after a charset tag, if one
  is present.

  * More robust connection sequence with New Relic servers

  A rare bug that could cause the agent's initial connection handshake with
  New Relic servers to silently fail has been fixed, and better logging has been
  added to the related code path to ease diagnosis of any future issues.

  * Prevent over-counting of queue time with nested transactions

  When using add_transaction_tracer on methods called from within a Rails or
  Sinatra action, it was previously possible to get inflated queue time
  measurements, because queue time would be recorded for both the outer
  transaction (the Rails or Sinatra action) and the inner transaction (the
  method given to add_transaction_tracer). This has been fixed, so only the
  outermost transaction will now record queue time.

## v3.7.3 ##

  * Obfuscation for PostgreSQL explain plans

  Fixes an agent bug with PostgreSQL where parameters from the original query
  could appear in explain plans sent to New Relic servers, even when SQL
  obfuscation was enabled. Parameters from the query are now masked in explain
  plans prior to transmission when transaction_tracer.record_sql is set to
  'obfuscated' (the default setting).

  For more information, see:
  https://docs.newrelic.com/docs/traces/security-for-postgresql-explain-plans

  * More accurate categorization of SQL statements

  Some SQL SELECT statements that were previously being mis-categorized as
  'SQL - OTHER' will now correctly be tagged as 'SQL - SELECT'. This
  particularly affected ActiveRecord users using PostgreSQL.

  * More reliable Typhoeus instrumentation

  Fixed an issue where an exception raised from a user-specified on_complete
  block would cause our Typhoeus instrumentation to fail to record the request.

  * Fix for Puma 2.8.0 cluster mode (3.7.3.204)

  Puma's 2.8.0 release renamed a hook New Relic used to support Puma's cluster
  mode.  This resulted in missing data for users running Puma. Thanks Benjamin
  Kudria for the fix!

  * Fix for deployment command bug (3.7.3.204)

  Problems with file loading order could result in `newrelic deployments`
  failing with an unrecognized command error. This has been fixed.

## v3.7.2 ##

  * Mongo instrumentation improvements

  Users of the 'mongo' MongoDB client gem will get more detailed instrumentation
  including support for some operations that were not previously captured, and
  separation of aggregate metrics for web transactions from background jobs.

  An issue with ensure_index when passed a symbol or string was also fixed.
  Thanks Maxime RETY for the report!

  * More accurate error tracing in Rails 4

  Traced errors in Rails 4 applications will now be correctly associated with
  the transaction they occurred in, and custom attributes attached to the
  transaction will be correctly attached to the traced error as well.

  * More accurate partial-rendering metrics for Rails 4

  View partials are now correctly treated as sub-components of the containing
  template render in Rails 4 applications, meaning that the app server breakdown
  graphs for Rails 4 transactions should be more accurate and useful.

  * Improved Unicorn 4.8.0 compatibility

  A rare issue that could lead to spurious traced errors on app startup for
  applications using Unicorn 4.8.0 has been fixed.

  * meta_request gem compatibility

  An incompatibility with the meta_request gem has been fixed.

  * Typhoeus 0.6.4+ compatibility

  A potential crash with Typhoeus 0.6.4+ when passing a URI object instead of a
  String instance to one of Typhoeus's HTTP request methods has been fixed.

  * Sequel single threaded mode fix

  The agent will no longer attempt to run EXPLAIN queries for slow SQL
  statements issued using the Sequel gem in single-threaded mode, since
  doing so could potentially cause crashes.

  * Additional functionality for add_custom_parameters

  Calling add_custom_parameters adds parameters to the system codenamed
  Rubicon. For more information, see http://newrelic.com/software-analytics

  * Update gem signing cert (3.7.2.195)

  The certificate used to sign newrelic_rpm expired in February. This patch
  updates that for clients installing with verification.

## v3.7.1 ##

  * MongoDB support

  The Ruby agent provides support for the mongo gem, versions 1.8 and 1.9!
  Mongo calls are captured for transaction traces along with their parameters,
  and time spent in Mongo shows up on the Database tab.

  Support for more Mongo gems and more UI goodness will be coming, so watch
  http://docs.newrelic.com/docs/ruby/mongo for up-to-date status.

  * Harvest thread restarts for forked and daemonized processes

  Historically framework specific code was necessary for the Ruby agent to
  successfully report data after an app forked or daemonized. Gems or scripts
  with daemonizing modes had to wait for agent support or find workarounds.

  With 3.7.1 setting `restart_thread_in_children: true` in your newrelic.yml
  automatically restarts the agent in child processes without requiring custom
  code. For now the feature is opt-in, but future releases may default it on.

  * Fix for missing HTTP time

  The agent previously did not include connection establishment time for
  outgoing Net::HTTP requests. This has been corrected, and reported HTTP
  timings should now be more accurate.

  * Fix for Mongo ensure_index instrumentation (3.7.1.182)

  The Mongo instrumentation for ensure_index in 3.7.1.180 was not properly
  calling through to the uninstrumented version of this method. This has been
  fixed in 3.7.1.182. Thanks to Yuki Miyauchi for the fix!

  * Correct first reported metric timespan for forking dispatchers (3.7.1.188)

  The first time a newly-forked process (in some configurations) reported metric
  data, it would use the startup time of the parent process as the start time
  for that metric data instead of its own start time. This has been fixed.

## v3.7.0 ##

  * Official Rubinius support (for Rubinius >= 2.2.1)

  We're happy to say that all known issues with the Ruby agent running on
  Rubinius have been resolved as of Rubinius version 2.2.1! See
  http://docs.newrelic.com/docs/ruby/rubinius for the most up-to-date status.

  * RUM injection updates

  The Ruby agent's code for both automatic and manual injection of Real User
  Monitoring scripts has been improved. No application changes are required, but
  the new injection logic is simpler, faster, more robust, and paves the way for
  future improvements to Real User Monitoring.

  * More robust communication with New Relic

  Failures when transmitting data to New Relic could cause data to be held over
  unnecessarily to a later harvest. This has been improved both to handle
  errors more robustly and consistently, and to send data as soon as possible.

  * Fix for agent not restarting on server-side config changes

  A bug in 3.6.9 caused the agent to not reset correctly after server-side
  config changes. New settings would not be received without a full process
  restart. This has been fixed.

  * Blacklisting rake spec tasks

  A blacklist helps the agent avoid starting during rake tasks. Some default
  RSpec tasks were missing. Thanks for the contribution Kohei Hasegawa!

## v3.6.9 ##

  * Experimental Rubinius 2.x support

  The agent is now being tested against the latest version of Rubinius. While
  support is still considered experimental, you can track the progress at
  http://docs.newrelic.com/docs/ruby/rubinius for up to date status.

  * Capture arguments for Resque and Sidekiq jobs

  The agent can optionally record arguments for your Resque and Sidekiq jobs on
  transaction traces and traced errors. This is disabled by default, but may be
  enabled by setting resque.capture_params or sidekiq.capture_params.

  Thanks to Juan Ignacio Pumarino, Ken Mayer, Paul Henry, and Eric Saxby for
  their help with this feature!

  * Supported versions rake task and documentation

  We've improved our documentation for what Ruby and gem versions we support.
  Run `rake newrelic:supported_versions` or see the latest agent's versions at
  https://docs.newrelic.com/docs/ruby/supported-frameworks.

  * ActiveRecord 4.0 explain plans for JRuby and Rubinius

  The agent's ActiveRecord 4.0 instrumentation could not gather SQL explain
  plans on JRuby by default because of a dependency on ObjectSpace, which isn't
  avialable by default. This has been fixed.

  * Fix for Curb http_put_with_newrelic

  A bug in the agent caused PUT calls in the Curb gem to crash. This has been
  fixed. Thanks to Michael D'Auria and Kirk Diggler for the contributions!

  * Fix for head position on RUM injection

  Certain unusual HTML documents resulted in browser monitoring injecting
  incorrect content. Thanks Alex McHale for the contribution!

  * Specify the Content-Type header in developer mode

  Thanks Jared Ning for the contribution!

## v3.6.8 ##

  * X-Ray Sessions support

  X-Ray Sessions provide more targeted transaction trace samples and thread
  profiling for web transactions. For full details see our X-Ray sessions
  documentation at https://newrelic.com/docs/site/xray-sessions.

  * Percentiles and Histograms

  The Ruby Agent now captures data that provides percentile and histogram views
  in the New Relic UI.

  * CPU metrics re-enabled for JRuby >= 1.7.0

  To work around a JRuby bug, the Ruby agent stopped gathering CPU metrics on
  that platform.  With the bug fixed, the agent can gather those metrics again.
  Thanks Bram de Vries for the contribution!

  * Missing Resque transaction traces (3.6.8.168)

  A bug in 3.6.8.164 prevented transaction traces in Resque jobs from being
  communicated back to New Relic. 3.6.8.168 fixes this.

  * Retry on initial connect (3.6.8.168)

  Failure to contact New Relic on agent start-up would not properly retry. This
  has been fixed.

  * Fix potential memory leak on failure to send to New Relic (3.6.8.168)

  3.6.8.164 introduced a potential memory leak when transmission of some kinds
  of data to New Relic servers failed. 3.6.8.168 fixes this.

## v3.6.7 ##

  * Resque-pool support

  Resque processes started via the resque-pool gem weren't recognized by the
  Ruby agent. The agent now starts correctly in those worker processes.

  * Environment-based configuration

  All settings in newrelic.yml can now be configured via environment variables.
  See https://newrelic.com/docs/ruby/ruby-agent-configuration for full details.

  * Additional locking option for Resque (3.6.7.159)

  There have been reports of worker process deadlocks in Resque when using the
  Ruby agent. An optional lock is now available to avoid those deadlocks. See
  https://newrelic.com/docs/ruby/resque-instrumentation for more details.

  * HTTP connection setup timeout (3.6.7.159)

  HTTP initialization in the agent lacked an appropriate timeout,
  leading to dropouts in reporting under certain network error conditions.

  * Unnecessary requests from Resque jobs (3.6.7.159)

  An issue causing Resque jobs to unnecessarily make requests against New Relic
  servers was fixed.

  * Fix compatibility issues with excon and curb instrumentation

  This release of the agent fixes a warning seen under certain circumstances
  with the excon gem (most notably, when excon was used by fog), as well as
  a bug with the curb instrumentation that conflicted with the  feedzirra gem.

  * Allow license key to be set by Capistrano variables

  A license key can be passed via a Capistrano variable where previously it
  could only be in newrelic.yml. Thanks Chris Marshall for the contribution!

  * Make HTTP client instrumentation aware of "Host" request header

  If a "Host" header is set explicitly on an HTTP request, that hostname will
  be used for external metrics. Thanks Mislav Marohnić for the contribution!

  * Fix ActiveSupport::Concern warnings with MethodTracer

  Including NewRelic::Agent::MethodTracer in a class using Concerns could cause
  deprecation warnings. Thanks Mike Połtyn for the contribution!

  * Fix Authlogic constant name

  Code checking for the Authlogic module was using in the wrong case. Thanks
  Dharam Gollapudi for the contribution!

## v3.6.6 ##

  * HTTPClient and Curb support

  The Ruby agent now supports the HTTPClient and Curb HTTP libraries! Cross
  application tracing and more is fully supported for these libraries. For more
  details see https://newrelic.com/docs/ruby/ruby-http-clients.

  * Sinatra startup improvements

  In earlier agent versions, newrelic_rpm had to be required after Sinatra to
  get instrumentation. Now the agent should start when your Sinatra app starts
  up in rackup, thin, unicorn, or similar web servers.

  * Puma clustered mode support

  Clustered mode in Puma was not reporting data without manually adding a hook
  to Puma's configuration. The agent will now automatically add this hook.

  * SSL certificate verification

  Early versions of the agent's SSL support provided an option to skip
  certificate verification. This option has been removed.

## v3.6.5 ##

  * Rails 4.0 Support

  The Ruby agent is all set for the recent general release of Rails 4.0! We've
  been tracking the RC's, and that work paid off. Versions 3.6.5 and 3.6.4 of
  the Ruby agent should work fine with Rails 4.0.0.

  * Excon and Typhoeus support

  The Ruby agent now supports the Excon and Typhoeus HTTP libraries! For more
  details see https://newrelic.com/docs/ruby/ruby-http-clients.

## v3.6.4 ##

  * Exception Whitelist

  We've improved exception message handling for applications running in
  high security mode. Enabling 'high_security' now removes exception messages
  entirely rather than simply obfuscating any SQL.

  By default this feature affects all exceptions, though you can configure a
  whitelist of exceptions whose messages should be left intact.

  More details: https://newrelic.com/docs/ruby/ruby-agent-configuration

  * Fix a race condition affecting some Rails applications at startup

  Some Rails applications using newrelic_rpm were affected by a race condition
  at startup that manifested as an error when model classes with associations
  were first loaded. The cause of these errors has been addressed by moving the
  generation of the agent's EnvironmentReport on startup from a background
  thread to the main thread.

## v3.6.3 ##

  * Better Sinatra Support

  A number of improvements have been made to our Sinatra instrumentation.
  More details: https://newrelic.com/docs/ruby/sinatra-support-in-the-ruby-agent

  Sinatra instrumentation has been updated to more accurately reflect the final
  route that was actually executed, taking pass and conditions into account.

  New Relic middlewares for error collection, real user monitoring, and cross
  application tracing are automatically inserted into the middleware stack.

  Ignoring routes, similar to functionality available to Rails controllers, is
  now available in Sinatra as well.

  Routes in 1.4 are properly formatting in transaction names. Thanks Zachary
  Anker for the contribution!

  * Padrino Support

  Along with improving our support of Sinatra, we've also extended that to
  supporting Padrino, a framework that builds on Sinatra. Web transactions
  should show up in New Relic now for Padrino apps automatically. The agent has
  been tested against the latest Padrino in versions 0.11.x and 0.10.x.

  * Main overview graph only shows web transactions

  In the past database times from background jobs mixed with other web transaction
  metrics in the main overview graph. This often skewed graphs. A common workaround
  was to send background jobs to a separate application, but that should no longer
  be necessary as the overview graphs now only represent web transactions.

## v3.6.2 ##

  * Sequel support

  The Ruby agent now supports Sequel, a database toolkit for Ruby. This
  includes capturing SQL calls and model operations in transaction traces, and
  recording slow SQL calls. See https://newrelic.com/docs/ruby/sequel-instrumentation
  for full details.

  * Thread profiling fix

  The prior release of the agent (version 3.6.1) broke thread profiling. A
  profile would appear to run, but return no data. This has been fixed.

  * Fix for over-counted Net::HTTP calls

  Under some circumstances, calls into Net::HTTP were being counted twice in
  metrics and transaction traces. This has been fixed.

  * Missing traced errors for Resque applications

  Traced errors weren't displaying for some Resque workers, although the errors
  were factored into the overall count graphs. This has been fixed, and traced
  errors should be available again after upgrading the agent.

## v3.6.1 ##

  * Full URIs for HTTP requests are recorded in transaction traces

  When recording a transaction trace node for an outgoing HTTP call via
  Net::HTTP, the agent will now save the full URI (instead of just the hostname)
  for the request. Embedded credentials, the query string, and the fragment will
  be stripped from the URI before it is saved.

  * Simplify Agent Autostart Logic

  Previously the agent would only start when it detected a supported
  "Dispatcher", meaning a known web server or background task framework.  This
  was problematic for customers using webservers that the agent was not
  configured to detect (e.g. Puma).  Now the agent will attempt to report any
  time it detects it is running in a monitored environment (e.g. production).
  There are two exceptions to this.  The agent will not autostart in a rails
  console or irb session or when the process was invoked by a rake task (e.g.
  rake assets:precompile).  The NEWRELIC_ENABLE environment variable can be set
  to true or false to force the agent to start or not start.

  * Don't attempt to resolve collector hostname when proxy is in use

  When a proxy is configured, the agent will not attempt to lookup and cache the
  IP address of New Relic server to which it is sending data, since DNS may not
  be available in some environments. Thanks to Bill Kirtley for the contribution

  * Added NewRelic::Agent.set_transaction_name and NewRelic::Agent.get_transaction_name

  Ordinarily the name of your transaction is defined up-front, but if you'd like to
  change the name of a transaction while it is still running you can use
  **NewRelic::Agent.set_transaction_name()**.  Similarly, if you need to know the name
  of the currently running transaction, you can use **NewRelic::Agent.get_transaction_name()**.

## v3.6.0 ##

  * Sidekiq support

  The Ruby agent now supports the Sidekiq background job framework. Traces from
  Sidekiq jobs will automatically show up in the Background tasks on New Relic
  similar to Resque and Delayed::Job tasks.

  * Improved thread safety

  The primary metrics data structures in the Ruby agent are now thread safe.
  This should provide better reliability for the agent under JRuby and threaded
  scenarios such as Sidekiq or Puma.

  * More robust environment report

  The agent's analysis of the local environment (e.g. OS, Processors, loaded
  gems) will now work in a wider variety of app environments, including
  Sinatra.

  * Experimental Rainbows! support

  The Ruby agent now automatically detects and instruments the Rainbows! web
  server. This support is considered experimental at present, and has not been
  tested with all dispatch modes.

  Thanks to Joseph Chen for the contribution.

  * Fix a potential file descriptor leak in Resque instrumentation

  A file descriptor leak that occurred when DontPerform exceptions were used to
  abort processing of a job has been fixed. This should allow the Resque
  instrumentation work correctly with the resque-lonely_job gem.

## v3.5.8 ##

  * Key Transactions

    The Ruby agent now supports Key Transactions! Check out more details on the
    feature at https://newrelic.com/docs/site/key-transactions

  * Ruby 2.0

    The Ruby agent is compatible with Ruby 2.0.0 which was just released.

  * Improved Sinatra instrumentation

    Several cases around the use of conditions and pass in Sinatra are now
    better supported by the Ruby agent. Thanks Konstantin for the help!

  * Outbound HTTP headers

    Adds a 'X-NewRelic-ID' header to outbound Net::HTTP requests. This change
    helps improve the correlation of performance between services in a service-
    oriented architecture for a forthcoming feature. In the meantime, to disable
    the header, set this in your newrelic.yml:

      cross_application_tracer:
        enabled: false

  * Automatically detect Resque dispatcher

    The agent does better auto-detection for the Resque worker process.
    This should reduce the need to set NEW_RELIC_DISPATCHER=resque directly.

## v3.5.7 ##

  * Resolved some issues with tracking of frontend queue time, particularly
    when the agent is running on an app hosted on Heroku.  The agent will now
    more reliably parse the headers described in
    https://newrelic.com/docs/features/tracking-front-end-time and will
    automatically detect whether the times provided are in seconds,
    milliseconds or microseconds.

## v3.5.6 ##

  * Use HTTPS by default

    The agent now defaults to using SSL when it communicates with New Relic's
    servers.  By default is already configured New Relic does not transmit any
    sensitive information (e.g. SQL parameters are masked), but SSL adds an
    additional layer of security.  Upgrading customers may need to remove the
    "ssl: false" directive from their newrelic.yml to enable ssl.  Customers on
    Jruby may need to install the jruby-openssl gem to take advantage of this
    feature.

  * Fix two Resque-related issues

    Fixes a possible hang on exit of an instrumented Resque master process
    (https://github.com/defunkt/resque/issues/578), as well as a file descriptor
    leak that could occur during startup of the Resque master process.

  * Fix for error graph over 100%

    Some errors were double counted toward the overall error total. This
    resulted in graphs with error percentages over 100%. This duplication did
    not impact the specific error traces captured, only the total metric.

  * Notice gracefully handled errors in Sinatra

    When show_exceptions was set to false in Sinatra, errors weren't caught
    by New Relic's error collector. Now handled errors also have the chance
    to get reported back.

  * Ruby 2.0 compatibility fixes

    Ruby 2.0 no longer finds protected methods by default, but will with a flag.
    http://tenderlovemaking.com/2012/09/07/protected-methods-and-ruby-2-0.html

    Thanks Ravil Bayramgalin and Charlie Somerville for the fixes.

  * Auto-detect Trinidad as dispatcher

    Code already existing for detecting Trinidad as a dispatcher, but was only
    accessible via an ENV variable. This now auto-detects on startup. Thanks
    Robert Rasmussen for catching that.

  * Coercion of types in collector communication

    Certain metrics can be recorded with a Ruby Rational type, which JSON
    serializes as a string rather than a floating point value. We now treat
    coerce each outgoing value, and log issues before sending the data.

  * Developer mode fix for chart error

    Added require to fix a NameError in developer mode for summary page. Thanks
    to Ryan B. Harvey.

  * Don't touch deprecated RAILS_ROOT if on Rails 3

    Under some odd startup conditions, we would look for the RAILS_ROOT constant
    after failing to find the ::Rails.root in a Rails 3 app, causing deprecation
    warnings. Thanks for Adrian Irving-Beer for the fix.

## v3.5.5 ##

  * Add thread profiling support

    Thread profiling performs statistical sampling of backtraces of all threads
    within your Ruby processes. This feature requires MRI >= 1.9.2, and is
    controlled via the New Relic web UI. JRuby support (in 1.9.x compat mode) is
    considered experimental, due to issues with JRuby's Thread#backtrace.

  * Add audit logging capability

    The agent can now log all of the data it sends to the New Relic servers to
    a special log file for human inspection. This feature is off by default, and
    can be enabled by setting the audit_log.enabled configuration key to true.
    You may also control the location of the audit log with the audit_log.path key.

  * Use config system for dispatcher, framework, and config file detection

    Several aspects of the agent's configuration were not being handled by the
    configuration system.  Detection/configuration of the dispatcher (e.g. passenger,
    unicorn, resque), framework (e.g. rails3, sinatra), and newrelic.yml
    location are now handled via the Agent environment, manual, and default
    configuration sources.

  * Updates to logging across the agent

    We've carefully reviewed the logging messages that the agent outputs, adding
    details in some cases, and removing unnecessary clutter. We've also altered
    the startup sequence to ensure that we don't spam STDOUT with messages
    during initialization.

  * Fix passing environment to manual_start()

    Thanks to Justin Hannus.  The :env key, when passed to Agent.manual_start,
    can again be used to specify which section of newrelic.yml is loaded.

  * Rails 4 support

    This release includes preliminary support for Rails 4 as of 4.0.0.beta.
    Rails 4 is still in development, but the agent should work as expected for
    people who are experimenting with the beta.

## v3.5.4 ##

  * Add queue time support for sinatra apps

    Sinatra applications can now take advantage of front end queue time
    reporting. Thanks to Winfield Peterson for this contribution.

  * Simplify queue time configuration for nginx 1.2.6+

    Beginning in version 1.2.6, recently released as a development version, the
    $msec variable can be used to set an http header.  This change allows front
    end queue time to be tracked in New Relic simply by adding this line to the
    nginx config:

    proxy_set_header X-Queue-Start "t=${msec}000"

    It will no longer be necessary to compile a patched version of nginx or
    compile in the perl or lua module to enable this functionality.

    Thanks to Lawrence Pit for the contribution.

  * Report back build number and stage along with version info

    In the 3.5.3 series the agent would fail to report its full version number
    to NewRelic's environment report.  For example it would report its version
    as 3.5.3 instead of 3.5.3.25 or 3.5.3.25.beta.  The agent will now report
    its complete version number as defined in newrelic_rpm.gemspec.

  * The host and the port that the agent reports to can now be set from environment vars

    The host can be set with NEW_RELIC_HOST and the port with NEW_RELIC_PORT.  These setting
    will override any other settings in your newrelic.yml.

  * Fix RUM reporting to multiple applications

    When the agent is configured to report to multiple "roll up" applications
    RUM did not work correctly.

## v3.5.3 ##

  * Update the collector protocol to use JSON and Ruby primitives

    The communication between the agent and the NewRelic will not longer be
    marshaled Ruby objects, but rather JSON in the case of Ruby 1.9 and marshaled
    Ruby primitives in the case of 1.8.  This results in greater harvest efficiency
    as well as feature parity with other New Relic agents.

  * Fix incorrect application of conditions in sinatra instrumentation

    The agent's sinatra instrumentation was causing sinatra's conditions to
    be incorrectly applied in some obscure cases.  The bug was triggered
    when a condition was present on a lower priority route that would match
    the current request, except for the presence of a higher priority route.

## v3.5.2 ##

 * Simplified process of running agent test suite and documented code
   contribution process in GUIDELINES_FOR_CONTRIBUTING.

## v3.5.1 ##

 * Enabling Memory Profiling on Lion and Mountain Lion

   The agent's list of supported platforms for memory profiling wasn't correctly checking
   for more recent versions of OS X.

 * Fixed an arity issue encountered when calling newrelic_notice_error from Rails applications.

 * End user queue time was not being properly reported, works properly now.

 * Server-side configuration for ignoring errors was not being heeded by agent.

 * Better handling of a thread safety issue.

   Some issues may remain, which we are working to address, but they should be gracefully handled
   now, rather than crashing the running app.

 * Use "java_import" rather than "include_class" when require Java Jars into a JRuby app.

   Thanks to Jan Habermann for the pull request

 * Replaced alias_method mechanism with super call in DataMapper instrumentation.

   Thanks to Michael Rykov for the pull request

 * Fixed the Rubinius GC profiler.

   Thanks to Dirkjan Bussink

 * Use ActiveSupport.on_load to load controller instrumentation Rails 3.

   Thanks to Jonathan del Strother

 * Reduce the number of thread local reference in a particular high traffic method

   Thanks to Jeremy Kemper

## v3.5.0.1 ##

 * (Fix) Due to a serious resource leak we have ended support for versions of Phusion Passenger
   older than 2.1.1. Users of older versions are encouraged upgrade to a more recent version.

## v3.5.0 ##

 * (Fix) RUM Stops Working After 3.4.2.1 Agent Upgrade

   v3.4.2.1 introduced a bug that caused the browser monitor auto instrumentation
   (for RUM) default to be false. The correct value of true is now used

 * When the Ruby Agent detects Unicorn as the dispatcher it creates an INFO level log message
   with additional information

   To help customers using Unicorn, if the agent detects it (Unicorn) is being used as the
   dispatcher an INFO level log message it created that includes a link to New Relic
   online doc that has additional steps that may be required to get performance data reporting.

 * (Fix) In version 3.4.2 of the Ruby Agent the server side value for Apdex T was disregarded

   With version 3.4.2 of the agent, the value set in the newrelic.yml file took precedence over the
   value set in the New Relic UI.  As of version 3.5.0 only the value for Apdex T set in the
   New Relic UI will be used. Any setting in the yaml file will be ignored.

 * Improved Error Detection/Reporting capabilities for Rails 3 apps

   Some errors are missed by the agent's exception reporting handlers because they are
   generated in the rails stack, outside of the instrumented controller action. A Rack
   middleware is now included that can detect these errors as they bubble out of the middleware stack.
   Note that this does not include Routing Errors.

 * The Ruby Agent now logs certain information it receives from the New Relic servers

   After connecting to the New Relic servers the agent logs the New Relic URL
   of the app it is reporting to.

 * GC profiling overhead for Ruby 1.9 reduced

   For Ruby 1.9 the amount of time spent in GC profiling has been reduced.

 * Know issue with Ruby 1.8.7-p334, sqlite3-ruby 1.3.0 or older, and resque 1.23.0

   The Ruby Agent will not work in conjunction with Ruby 1.8.7-p334, sqlite3-ruby 1.3.3
   or earlier, and resque 1.23.0. Your app will likely stop functioning. This is a known problem
   with Ruby versions up to 1.8.7-p334. Upgrading to the last release of Ruby 1.8.7
   is recommended.  This issue has been present in every version of the agent we've tested
   going back for a year.


## v3.4.2.1 ##

* Fix issue when app_name is nil

  If the app_name setting ends up being nil an exception got generated and the application
  wouldn't run. This would notably occur when running a Heroku app locally without the
  NEW_RELIC_APP_NAME environment variable set. A nil app_name is now detected and an
  error logged specifying remediation.

## v3.4.2 ##

 * The RUM NRAGENT tk value gets more robustly sanitized to prevent potential XSS vulnerabilities

   The code that scrubs the token used in Real User Monitoring has been enhanced to be
   more robust.

 * Support for Apdex T in server side configuration

   For those using server side configuration the Ruby Agent now supports setting
   the Apdex T value via the New Relic UI.

 * Refactoring of agent config code

   The code that reads the configuration information and configures the agent
   got substantially reorganized, consolidated, simplified, and made more robust.

## v3.4.1 ##
#### Bug Fixes ####
 * Fix edge case in RUM auto instrumentation where X-UA-Compatible meta tag is
   present but </head> tag is missing.

   There is a somewhat obscure edge case where RUM auto instrumentation will
   crash a request. The issue seems to be triggered when the X-UA-Compatible
   meta tag is present and the </head> tag is missing.

 * Fixed reference to @service.request_timeout to @request_timeout in
   new_relic_service.rb. (Thanks to Matthew Savage)

   When a timeout occurred during connection to the collector an "undefined
   method `request_timeout' for nil:NilClass'" would get raised.

 * preserve visibility on traced methods.

   Aliased methods now have the same visibility as the original traced method.
   A couple of the esoteric methods created in the process weren't getting the
   visibility  set properly.

 * Agent service does not connect to directed shard collector after connecting
   to proxy

   After connecting to collector proxy name of real collector was updated, but
   ip address was not being updated causing connections to go to the proxy.
   Agent now looks up ip address for real collector.

 * corrupt marshal data from pipe children crashing agent

   If the agent received corrupted data from the Reqsue worker child agent
   it could crash the agent itself. fixed.

 * should reset RubyBench GC counter between polls

   On Ruby REE, the GC profiler does not reset the counter between polls. This
   is only a problem if GC could happen *between* transactions, as in, for
   example, out-of-band GC in Unicorn. fixed.

## v3.4.0.1
 * Prevent the agent from resolving the collector address when disabled.
 * Fix for error collector configuration that was introduced during beta.
 * Preserve method visibility when methods are traced with #add_method_tracer and #add_transaction_tracer

## v3.4.0
 * Major refactor of data transmission mechanism.  This enabled child processes to send data to parent processes, which then send the data to the New Relic service.  This should only affect Resque users, dramatically improving their experience.
 * Moved Resque instrumentation from rpm_contrib to main agent.  Resque users should discontinue use of rpm_contrib or upgrade to 2.1.11.
 * Resolve issue with configuring the Error Collector when using server-side configuration.

## v3.3.5
 * [FIX] Allow tracing of methods ending in ! and ?
 * [PERF] Give up after scanning first 50k of the response in RUM
   auto-instrumentation.
 * [FIX] Don't raise when extracting metrics from SQL queries with non UTF-8 bytes.
 * Replaced "Custom/DJ Locked Jobs" metric with new metrics for
   monitoring DelayedJob: queue_length, failed_jobs, and locked_jobs, all under
   Workers/DelayedJob.  queue_length is also broken out by queue name or priority
   depending on the version of DelayedJob deployed.

## v3.3.4.1
 * Bug fix when rendering empty collection in Rails 3.1+

## v3.3.4
  * Rails 3 view instrumentation

## v3.3.3
  * Improved Sinatra instrumentation
  * Limit the number of nodes collected in long running transactions to prevent leaking memory

## v3.3.2.1
  * [SECURITY] fix for cookie handling by End User Monitoring instrumentation

## v3.3.2
  * deployments recipe change: truncate git SHAs to 7 characters
  * Fixes for obfuscation of PostgreSQL and SQLite queries
  * Fix for lost database connections when using a forking framework
  * Workaround for RedHat kernel bug which prevented blocking reads of /proc fs
  * Do not trap signals when handling exceptions

## v3.3.1
  * improved Ruby 1.8.6 support
  * fix for issues with RAILS_ROOT deprecation warnings
  * fixed incorrect 1.9 GC time reporting
  * obfuscation for Slow SQL queries respects transaction trace config
  * fix for RUM instrumentation repoting bad timing info in some cases
  * refactored ActiveRecord instrumentation, no longer requires Rails

## v3.3.0
  * fix for GC instrumentation when using Ruby 1.9
  * new feature to correlate browser and server transaction traces
  * new feature to trace slow sql statements
  * fix to help cope with malformed rack responses
  * do not try to instrument versions of ActiveMerchant that are too old

## v3.2.0.1
  * Updated LICENSE
  * Updated links to support docs

## v3.2.0
  * Fix over-detection of mongrel and unicorn and only start the agent when
    actual server is running
  * Improve developer mode backtraces to support ruby 1.9.2, windows
  * Fixed some cases where Memcache instrumentation was failing to load
  * Ability to set log destination by NEW_RELIC_LOG env var
  * Fix to mutex lib load issue
  * Performance enhancements (thanks to Jeremy Kemper)
  * Fix overly verbose STDOUT message (thanks to Anselm Helbig)

## v3.1.2
  * Fixed some thread safety issues
  * Work around for Ruby 1.8.7 Marshal crash bug
  * Numerous community patches (Gabriel Horner, Bradley Harris, Diego Garcia,
    Tommy Sullivan, Greg Hazel, John Thomas Marino, Paul Elliott, Pan Thomakos)
  * Fixed RUM instrumentation bug

## v3.1.1
  * Support for Rails 3.1 (thanks to Ben Hoskings via github)
  * Support for Rubinius
  * Fixed issues affecting some Delayed Job users where log files were not appearing
  * Fixed an issue where some instrumentation might not get loaded in Rails apps
  * Fix for memcached cas method (thanks to Andrew Long and Joseph Palermo )
  * Fix for logger deprecation warning (thanks to Jonathan del Strother via github)
  * Support for logging to STDOUT
  * Support for Spymemcached client on jruby

## v3.1.0
  * Support for aggregating data from short-running
    processes to reduce reporting overhead
  * Numerous bug fixes
  * Increased unit test coverage

## v3.0.1
  * Updated Real User Monitoring to reduce javascript size and improve
    compatibility, fix a few known bugs

## v3.0.0
  * Support for Real User Monitoring
  * Back end work on internals to improve reliability
  * added a 'log_file_name' and 'log_file_path' configuration variable to allow
    setting the path and name of the agent log file
  * Improve reliability of statistics calculations
  * Remove some previously deprecated methods
  * Remove Sequel instrumentation pending more work

## v2.14.1
  * Avoid overriding methods named 'log' when including the MethodTracer module
  * Ensure that all load paths for 'new_relic/agent' go through 'new_relic/control' first
  * Remove some debugging output from tests

## v2.14.0
  * Dependency detection framework to prevent multi-loading or early-loading
    of instrumentation files

## v2.13.5
  * Moved the API helper to the github newrelic_api gem.
  * Revamped queue time to include server, queue, and middleware time
  * Increased test coverage and stability
  * Add Trinidad as a dispatcher (from Calavera, on github)
  * Sequel instrumentation from Aman Gupta
  * patches to 1.9 compatibility from dkastner on github
  * Support for 1.9.2's garbage collection instrumentation from Justin Weiss
  * On Heroku, existing queue time headers will be detected
  * Fix rack constant scoping in dev mode for 1.9 (Rack != ::Rack)
  * Fixes for instrumentation loading failing on Exception classes that
    are not subclasses of StandardError
  * Fix active record instrumentation load order for Rails 3

## v2.13.4
  * Update DNS lookup code to remove hardcoded IP addresses

## v2.13.3
  * Dalli instrumentation from Mike Perham (thanks Mike)
  * Datamapper instrumentation from Jordan Ritter (thanks Jordan)
  * Apdex now defaults to 0.5
    !!! Please be aware that if you are not setting an apdex,
    !!! this will cause a change in the apparent performance of your app.
  * Make metric hashes threadsafe (fixes problems sending metrics in Jruby
    threaded code)
  * Delete obsolete links to metric docs in developer mode
  * Detect gems when using Bundler
  * Fix newrelic_ignore in Rails 3
  * Break metric parser into a separate vendored gem
  * When using Unicorn, preload_app: true is recommended to get proper
    after_fork behavior.

## v2.13.2
  * Remove a puts. Yes, a whole release for a puts.

## v2.13.1
  * Add missing require in rails 3 framework control

## v2.13.0
  * developer mode is now a rack middleware and can be used on any framework;
    it is no longer supported automatically on versions of Rails prior to 2.3;
    see README for details
  * memcache key recording for transaction traces
  * use system_timer gem if available, fall back to timeout lib
  * address instability issues in JRuby 1.2
  * renamed executable 'newrelic_cmd' to 'newrelic'; old name still supported
    for backward compatibility
  * added 'newrelic install' command to install a newrelic.yml file in the
    current directory
  * optimization to execution time measurement
  * optimization to startup sequence
  * change startup sequence so that instrumentation is installed after all
    other gems and plugins have loaded
  * add option to override automatic flushing of data on exit--send_data_on_exit
    defaults to 'true'
  * ignored errors no longer affect apdex score
  * added record_transaction method to the api to allow recording
    details from web and background transactions occurring outside RPM
  * fixed a bug related to enabling a gold trial / upgrade not sending
    transaction traces correctly

## v2.12.3
  * fix regression in startup sequence

## v2.12.2
  * fix for regression in Rails 2.1 inline rendering
  * workaround bug found in some rubies that caused a segv and/or NoMemoryError
    when deflating content for upload
  * avoid creating connection thread in unicorn/passenger spawners

## v2.12.1
  * fix bug in profile mode
  * fix race condition in Delayed::Job instrumentation loading
  * fix glassfish detection in latest glassfish gem

## v2.12.0
  * support basic instrumentation for ActsAsSolr and Sunspot

## v2.11.3
  * fix bug in startup when running JRuby

## v2.11.2
  * fix for unicorn not reporting when the proc line had 'master' in it
  * fix regression for passenger 2.0 and earlier
  * fix after_fork in the shim

## v2.11.1
  * republished gem without generated rdocs

## v2.11.0
  * rails3 instrumentation (no developer mode support yet)
  * removed the ensure_worker_thread started and instead defined an after_fork
    handler that will set up the agent properly in forked processes.
  * change at_exit handler so the shutdown always goes after other shutdown
    handlers
  * add visibility to active record db transactions in the rpm transaction
    traces (thanks to jeremy kemper)
  * fix regression in merb support which caused merb apps not to start
  * added NewRelic::Agent.logger to the public api to write to the agent
    log file.
  * optimizations to background thread, controller instrumentation, memory
    usage
  * add logger method to public_api
  * support list notation for ignored exceptions in the newrelic.yml

## v2.10.8
  * fix bug in delayed_job instrumentation that caused the job queue sampler
    to run in the wrong place
  * change startup sequence and code that restarts the worker loop
    thread
  * detect the unicorn master and dont start the agent; hook in after_fork
  * fix problem with the Authlogic metric names which caused errors in
    developer mode.  Authlogic metrics now adhere to the convention of
    prefixing the name with  'Custom'
  * allow more correct overriding of transaction trace settings in the
    call to #manual_start
  * simplify WorkerLoop and add better protection for concurrency
  * preliminary support for rails3

## v2.10.6
  * fix missing URL and referrer on some traced errors and transactions
  * gather traced errors *after* executing the rescue chain in ActionController
  * always load controller instrumentation
  * pick up token validation from newrelic.yml

## v2.10.5
  * fix bug in delayed_job instrumentation occurring when there was no DJ log

## v2.10.4
  * fix incompatibility with Capistrano 2.5.16
  * strip down URLs reported in transactions and errors to path only

## v2.10.3
  * optimization to reduce overhead: move background samplers into foreground thread
  * change default config file to ignore RoutingErrors
  * moved the background task instrumentation into a separate tab in the RPM UI
  * allow override of the RPM application name via NEWRELIC_APP_NAME environment variable
  * revised Delayed::Job instrumentation so no manual_start is required
  * send buffered data on shutdown
  * expanded support for queue length and queue time
  * remove calls to starts_with to fix Sinatra and non-rails deployments
  * fix problem with apdex scores recording too low in some circumstances
  * switch to jeweler for gem building
  * minor fixes, test improvements, doc and rakefile improvements
  * fix incompatibility with Hoptoad where Hoptoad was not getting errors handled by New Relic
  * many other optimizations, bug fixes and documentation improvements

## v2.10.2.
  * beta release of 2.10
  * fix bugs with Sinatra app instrumentation
  * minor doc updates

## v2.10.1.
  * alpha release of 2.10
  * rack support, including metal; ignores 404s; requires a module inclusion (see docs)
  * sinatra support, displays actions named by the URI pattern matched
  * add API method to abort transaction recording for in-flight transactions
  * remove account management calls from newrelic_api.rb
  * truncating extremely large transaction traces for efficiency
  * fix error reporting in recipes; add newrelic_rails_env option to recipes to
    override the rails env used to pull the app_name out of newrelic.yml
  * added TorqueBox recognition (thanks Bob McWhirter)
  * renamed config settings: enabled => monitor_mode; developer => developer_mode;
    old names will still work in newrelic.yml
  * instrumentation for DelayedJob (thanks Travis Tilley)
  * added config switches to turn off certain instrumentation when you aren't
    interested in the metrics, to save on overhead--see newrelic.yml for details.
  * add profiling support to dev mode; very experimental!
  * add 'multi_threaded' config option to indicate when the app is running
    multi-threaded, so we can disable some instrumentation
  * fix test failures in JRuby, REE
  * improve Net::HTTP instrumentation so it's more efficient and distinguishes calls
    between web and non-web transactions.
  * database instrumentation notices all database commands in addition to the core commands
  * add support for textmate to dev mode
  * added add_transaction_tracer method to support instrumenting methods as
    if they were web transactions; this will facilitate better visibility of background
    tasks and eventually things like rack, metal and Sinatra
  * adjusted apdex scores to reflect time spent in the mongrel queue
  * fixed incompatibility with JRuby on startup
  * implemented CPU measure for JRuby which reflects the cpu burn for
    all controller actions (does not include background tasks)
  * fixed scope issue with GC instrumentation, subtracting time from caller
  * added # of GC calls to GC instrumentation
  * renamed the dispatcher metric
  * refactored stats_engine code for readability
  * optimization: reduce wakeup times for harvest thread

## v2.10.0.
  * alpha release of 2.10
  * support unicorn
  * instrumentation of GC for REE and MRE with GC patch
  * support agent restarting when changes are made to the account
  * removed #newrelic_notice_error from Object class, replaced by NewRelic::Agent#notice_error
  * collect histogram statistics
  * add custom parameters to newrelic_notice_error call to display
    extra info for errors
  * add method disable_all_tracing(&block) to execute a block without
    capturing metrics
  * newrelic_ignore now blocks all instrumentation collection for
    the specified actions
  * added doc to method_tracer API and removed second arg
    requirement for add_method_tracer call
  * instrumentation for Net::HTTP
  * remove method_tracer shim to avoid timing problems in monitoring daemons
  * for non-rails daemons, look at APP_ROOT and NRCONFIG env vars for custom locations

## v2.9.9.
  * Disable at_exit handler for Unicorn which sometimes caused the
    agent to stop reporting immediately.

## v2.9.8.
  * add instrumentation for Net::HTTP calls, to show up as "External"
  * added support for validating agents in the cloud.
  * recognize Unicorn dispatcher
  * add NewRelic module definitions to ActiveRecord instrumentation

## v2.9.5.
  * Snow Leopard memory fix

## v2.9.4.
  * clamp size of data sent to server
  * reset statistics for passenger when forking to avoid erroneous data
  * fix problem deserializing errors from the server
  * fix incompatibility with postgres introduced in 2.9.

## v2.9.3.
  * fix startup failure in Windows due to memory sampler
  * add JRuby environment information

## v2.9.2.
  * change default apdex_t to 0.5 seconds
  * fix bug in deployments introduced by multi_homed setting
  * support overriding the log in the agent api
  * fix JRuby problem using objectspace
  * display custom parameters when looking at transactions in dev mode
  * display count of sql statements on the list of transactions in dev mode
  * fixes for merb--thanks to Carl Lerche

## v2.9.1.
  * add newrelic_ignore_apdex method to controller classes to allow
    you to omit some actions from apdex statistics
  * Add hook for Passenger shutdown events to get more timely shutdown
    notices; this will help in more accurate memory readings in
    Passenger
  * add newrelic_notice_error to Object class
  * optional ability to verify SSL certificates, note that this has some
    performance and reliability implications
  * support multi-homed host with multiple apps running on duplicate
    ports

## v2.9.0.
  Noteworthy Enhancements
  * give visibility to templates and partials in Rails 2.1 and later, in
    dev mode and production
  * change active record metrics to capture statistics in adapter log()
    call, resulting in lower overhead and improved visibility into
    different DB operations; only AR operations that are not hitting the
    query cache will be measured to avoid overhead
  * added mongrel_rpm to the gem, a standalone daemon listening for custom
    metric values sent from local processes (experimental); do mongrel_rpm
    --help
  * add API for system monitoring daemons (refer to KB articles); changed
    API for manual starting of the agent; refer to
    NewRelic::Agent.manual_start for details
  * do certificate verification on ssl connections to
    collector.newrelic.com
  * support instances appearing in more than one application by allowing a
    semicolon separated list of names for the newrelic.yml app_name
    setting.
  * combined agent logfiles into a single logfile
  * use rpm server time for transaction traces rather than agent time

  Developer Mode (only) Enhancements
  * show partial rendering in traces
  * improved formatting of metric names in traces
  * added number of queries to transactions in the transaction list
  * added some sorting options for the transaction list
  * added a page showing the list of active threads

  Compatibility Enhancements
  * ruby 1.9.1 compatibility
  * support concurrency when determining busy times, for 2.2 compatibility
  * in jruby, use Java used heap for memory sampling if the system memory
    is not accessible from an unsupported platform
  * jruby will no longer start the agent now when running the console or
    rake tasks
  * API support for RPM as a footnote add-in
  * webrick support restored

  Noteworthy bugfixes
  * sample memory on linux by reading /proc/#{$$}/status file
  * fixed ambiguous 'View' metrics showing up in controller breakdown
  * removed Numeric extensions, including round_to, and to_ms
  * using a different timeout mechanism when we post data to RPM
  * remove usage of Rails::Info which had a side effect of enabling
    ActiveRecord even when it wasn't an active framework
  * moved CPU sampler off background thread and onto the harvest thread
  * tests now run cleanly in any rails app using test:newrelic or
    test:plugins

  Agent improvements to support future RPM enhancements
  * add instrumentation to capture metrics on response codes; not yet
    working in rails 2.3.*
  * added http referrer to traced errors
  * capture gem requirements from rails
  * capture cpu utilization adjusted for processor count
  * transaction sampling

## v2.8.10.
  * fix thin support with rails 2.3.2 when using script/server
  * fix incompatibility with rails 2.3.2 and script/server options
    processing
  * minor tweak to environment gathering for gem mode

## v2.8.9.
  * fix problem finding the newrelic controller in dev mode
  * fix incompatibility with older versions of optparse
  * fix potential jvm problem with jruby
  * remove test:all task definition to avoid conflicts
  * change error message about window sampler in windows not supported to a
    warning message

## v2.8.8.
  * fix error with jruby on windows
  * fix problem where webrick was being incorrectly detected causing some
    problems with mongrel application assignments--had to disable webrick
    for now

## v2.8.7.
  * fix for ssl connection hanging problems
  * fix problem recognizing mongrel in rails 2.3.2
  * fastcgi support in rails 2.3.2
  * put back webrick support

## v2.8.6.
  * fix for capture_params when using file uploads in controller actions
  * use pure ruby NS lookup for collector host to eliminate possibly
    blocking applications

## v2.8.5.
  * fix reference to CommandError which was breaking some cap scripts
  * fix incompatibility with Rails 2.0 in the server API
  * fix problem with litespeed with Lite accounts
  * fix problem when ActiveRecord is disabled
  * moved merb instrumentation to Merb::Controller instead of
    AbstractController to address incompatibility with MailController
  * fix problem in devmode displaying sql with embedded urls

## v2.8.4.
  * fix bug in capistrano recipe causing cap commands to fail with error
    about not finding Version class

## v2.8.3.
  * refactor unit tests so they will run in a generic rails environment
  * require classes in advance to avoid autoloading.  this is to address
    incompatibilities with desert as well as more flexibility in gem
    initialization
  * fixed newrelic_helper.rb 1.9 incompatibility

## v2.8.2.
  * fix Ruby 1.9 syntax compatibility errors
  * update the class loading sanity check, will notify server of errors
  * fix agent output on script and rake task execution

## v2.8.1.
  * Convert the deployment information upload script to an executable and
    put in the bin directory.  When installed as a gem this command is
    symlinked to /usr/bin.  Usage: newrelic_cmd deployments --help
  * Fix issue invoking api when host is not set in newrelic.yml
  * Fix deployments api so it will work from a gem
  * Fix thin incompatibility in developer mode

## v2.8.0.
  * add beta of api in new_relic_api.rb
  * instrumented dynamic finders in ActiveRecord
  * preliminary support for capturing deployment information via capistrano
  * change memory sampler for solaris to use /usr/bin/ps
  * allow ERB in newrelic.yml file
  * merged support for merb into this version
  * fix incompatibility in the developer mode with the safe_erb plugin
  * fix module namespace issue causing an error accessing
    NewRelic::Instrumentation modules
  * fix issue where the agent sometimes failed to start up if there was a
    transient network problem
  * fix IgnoreSilentlyException message

## v2.7.4.
  * fix error when trying to serialize some kinds of Enumerable objects
  * added extra debug logging
  * added app_name to app mapping

## v2.7.3.
  * fix compatibility issue with 1.8.5 causing error with Dir.glob

## v2.7.2.
  * fix problem with passenger edge not being a detected environment

## v2.7.1.
  * fix problem with skipped dispatcher instrumentation

## v2.7.0.
  * Repackage to support both plugin and Gem installation
  * Support passenger/litespeed/jruby application naming
  * Update method for calculating dispatcher queue time
  * Show stack traces in RPM Transaction Traces
  * Capture error source for TemplateErrors
  * Clean up error stack traces.
  * Support query plans from postgres
  * Performance tuning
  * bugfixes

## v2.5.3.
  * fix error in transaction tracing causing traces not to show up

## v2.5.2.
  * fixes for postgres explain plan support

## v2.5.1.
  * bugfixes

## v2.5.0.
  * add agent support for rpm 1.1 features
  * Fix regression error with thin support

## v2.4.3.
  * added 'newrelic_ignore' controller class method with :except and :only options for finer grained control
    over the blocking of instrumentation in controllers.
  * bugfixes

## v2.4.2.
  * error reporting in early access

## v2.4.1.
  * bugfix: initializing developer mode

## v2.4.0.
  * Beta support for LiteSpeed and Passenger

## v2.3.7.
  * bugfixes

## v2.3.6.
  * bugfixes

## v2.3.5.
  * bugfixes: pie chart data, rails 1.1 compatibility

## v2.3.4.
  * bugfix

## v2.3.3.
  * bugfix for non-mysql databases

## v2.3.2.
  * bugfixes
  * Add enhancement for Transaction Traces early access feature

## v2.3.1.
  * bugfixes

## v2.3.0.
  + Add support for Transaction Traces early access feature

## v2.2.2.
  * bugfixes

## v2.2.1.
  + Add rails 2.1 support for Developer Mode
  + Changes to memory sampler: Add support for JRuby and fix Solaris support.
  * Stop catching exceptions and start catching StandardError; other exception cleanup
  * Add protective exception catching to the stats engine
  * Improved support for thin domain sockets
  * Support JRuby environments

## v2.1.6.
  * bugfixes

## v2.1.5.
  * bugfixes

## v2.1.4.
  * bugfixes

## v2.1.3.
  * bugfixes

## v2.1.2.
  * bugfixes

## v2.1.1.
  * bugfixes

## v2.1.0.
  * release for private beta
