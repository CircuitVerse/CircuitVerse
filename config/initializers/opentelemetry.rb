# frozen_string_literal: true

if ENV["ENABLE_OTEL"] == "true"
  require "opentelemetry/sdk"
  require "opentelemetry/exporter/otlp"

  OpenTelemetry::SDK.configure do |c|
    c.service_name = ENV.fetch("OTEL_SERVICE_NAME", "CircuitVerse")
    # Sampling follows the standard OTEL_TRACES_SAMPLER and
    # OTEL_TRACES_SAMPLER_ARG environment variables (e.g.
    # parentbased_traceidratio with OTEL_TRACES_SAMPLER_ARG=0.1).
    # The SDK defaults to always-on sampling when they are unset.
    # c.use_all
    c.use "OpenTelemetry::Instrumentation::ActionJob"
    c.use "OpenTelemetry::Instrumentation::ActionPack"
    c.use "OpenTelemetry::Instrumentation::ActionView"
    c.use "OpenTelemetry::Instrumentation::ActiveJob"
    c.use "OpenTelemetry::Instrumentation::ActiveModelSerializers"
    c.use "OpenTelemetry::Instrumentation::ActiveRecord"
    c.use "OpenTelemetry::Instrumentation::ActiveSupport"
    c.use "OpenTelemetry::Instrumentation::AwsSdk"
    c.use "OpenTelemetry::Instrumentation::ConcurrentRuby"
    c.use "OpenTelemetry::Instrumentation::Faraday"
    c.use "OpenTelemetry::Instrumentation::HTTP"
    c.use "OpenTelemetry::Instrumentation::Net::HTTP"
    c.use "OpenTelemetry::Instrumentation::PG"
    c.use "OpenTelemetry::Instrumentation::Rack"
    c.use "OpenTelemetry::Instrumentation::Rails"
    c.use "OpenTelemetry::Instrumentation::Redis"
    c.use "OpenTelemetry::Instrumentation::Sidekiq"
  end
end
