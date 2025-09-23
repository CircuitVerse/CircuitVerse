# Release History: opentelemetry-instrumentation-net_http

### v0.24.0 / 2025-08-26

* ADDED: Add `OTEL_SEMCONV_STABILITY_OPT_IN` environment variable compatibility [#1572](https://github.com/open-telemetry/opentelemetry-ruby-contrib/pull/1572)

### v0.23.1 / 2025-08-13

* FIXED: net_http and aws_sdk ci fix

### v0.23.0 / 2025-01-16

* BREAKING CHANGE: Set minimum supported version to Ruby 3.1

* ADDED: Set minimum supported version to Ruby 3.1

### v0.22.8 / 2024-11-26

* CHANGED: Performance Freeze all range objects #1222

### v0.22.7 / 2024-07-23

* DOCS: Add cspell to CI

### v0.22.6 / 2024-06-18

* FIXED: Relax otel common gem constraints

### v0.22.5 / 2024-05-09

* FIXED: Untrace entire request

### v0.22.4 / 2023-11-23

* CHANGED: Applied Rubocop Performance Recommendations [#727](https://github.com/open-telemetry/opentelemetry-ruby-contrib/pull/727)

### v0.22.3 / 2023-11-22

* FIXED: Update `Net::HTTP` instrumentation to no-op on untraced contexts

### v0.22.2 / 2023-07-21

* ADDED: Update `opentelemetry-common` from [0.19.3 to 0.20.0](https://github.com/open-telemetry/opentelemetry-ruby-contrib/pull/537)

### v0.22.1 / 2023-06-05

* FIXED: Base config options

### v0.22.0 / 2023-04-17

* BREAKING CHANGE: Drop support for EoL Ruby 2.7

* ADDED: Drop support for EoL Ruby 2.7
* FIXED: Drop Rails dependency for ActiveSupport Instrumentation

### v0.21.1 / 2023-01-14

* FIXED: Add untraced check to the Net::HTTP connect instrumentation
* DOCS: Fix gem homepage
* DOCS: More gem documentation fixes

### v0.21.0 / 2022-10-04

* ADDED: Add Net::HTTP :untraced_hosts option
* FIXED: Rename HTTP CONNECT for low level connection spans

### v0.20.0 / 2022-06-09

* Upgrading Base dependency version
* FIXED: Broken test file requirements

### v0.19.5 / 2022-05-05

* (No significant changes)

### v0.19.4 / 2022-02-02

* FIXED: Clientcontext attrs overwrite in net::http
* FIXED: Excessive hash creation on context attr merging

### v0.19.3 / 2021-12-01

* FIXED: Change net attribute names to match the semantic conventions spec for http

### v0.19.2 / 2021-09-29

* (No significant changes)

### v0.19.1 / 2021-08-12

* DOCS: Update docs to rely more on environment variable configuration

### v0.19.0 / 2021-06-23

* BREAKING CHANGE: Total order constraint on span.status=

* FIXED: Total order constraint on span.status=

### v0.18.0 / 2021-05-21

* ADDED: Updated API dependency for 1.0.0.rc1

### v0.17.0 / 2021-04-22

* FIXED: Refactor propagators to add #fields

### v0.16.0 / 2021-03-17

* FIXED: Example scripts now reference local common lib
* DOCS: Replace Gitter with GitHub Discussions

### v0.15.0 / 2021-02-18

* ADDED: Add Net::HTTP#connect tracing

### v0.14.0 / 2021-02-03

* BREAKING CHANGE: Replace getter and setter callables and remove rack specific propagators

* ADDED: Replace getter and setter callables and remove rack specific propagators

### v0.13.0 / 2021-01-29

* (No significant changes)

### v0.12.0 / 2020-12-24

* (No significant changes)

### v0.11.0 / 2020-12-11

* FIXED: Copyright comments to not reference year

### v0.10.0 / 2020-12-03

* (No significant changes)

### v0.9.0 / 2020-11-27

* ADDED: Add common helpers

### v0.8.0 / 2020-10-27

* BREAKING CHANGE: Remove 'canonical' from status codes

* FIXED: Remove 'canonical' from status codes

### v0.7.0 / 2020-10-07

* DOCS: Added documentation for net_http gem in instrumentation
* DOCS: Standardize top-level docs structure and readme

### v0.6.0 / 2020-09-10

* (No significant changes)
