# OpenTelemetry ~ CircuitVerse: Jaeger and New Relic

CircuitVerse employes Distributed tracing using [Jaeger service](https://www.jaegertracing.io/) and New Relic. Comprehensive documentation is available in the [Runbook](https://github.com/CircuitVerse/infra/tree/main/runbooks/docs/opentelemetry)

## Setup

Before starting the containers, following environment variables need to be set as mentioned in [env.example](./env.example):

1. `ENABLE_OTEL=true` - in order to generate spans
2. `NEW_RELIC_API_KEY=<new-relic-license-key-here>` - API key to aunthenticate to New Relic endpoint (optional)

```bash
export ENABLE_OTEL=true
export NEW_RELIC_API_KEY=<new-relic-license-key-here>
cd .otel
docker compose up -d
```

Navigate to [http://localhost:16686/](http://localhost:16686/) to view the Jaeger UI dashboard and view the traces.

## New Relic OpenTelemetry

In order to export Telemetry data to New Relic, you must have [New Relic Agent](https://docs.newrelic.com/docs/infrastructure/install-infrastructure-agent/get-started/install-infrastructure-agent/) installed and configured on the server.

`NEW_RELIC_API_KEY` (license key) can be located within the [API keys Dashboard](https://one.newrelic.com/launcher/api-keys-ui.api-keys-launcher).

New Relic OpenTelemetry endpoints are region-specific, by default it is US based. If you're using the EU data center region, use an EU endpoint in [otel-config.yaml](./otel-config.yaml).

```bash
# EU data center
https://otlp.eu01.nr-data.net

# US data center
https://otlp.nr-data.net
```

In order to ensure a smooth experience with distributed tracing using New Relic, traces are sent in batch process to avoid rate limiting.

For best practices refer - [New Relic otel best practices](https://docs.newrelic.com/docs/more-integrations/open-source-telemetry-integrations/opentelemetry/best-practices/opentelemetry-best-practices-overview/)

## Traces

- Jaeger UI dashboard: [http://localhost:16686](http://localhost:16686)
- New Relic dashboard: [https://one.newrelic.com/distributed-tracing](https://one.newrelic.com/distributed-tracing)

## Resources

- [Runbook](https://github.com/CircuitVerse/infra/tree/main/runbooks/docs/opentelemetry)
- [OpenTelemetry docs](https://opentelemetry.io/docs/)
- [New Relic OTEL docs](https://docs.newrelic.com/docs/more-integrations/open-source-telemetry-integrations/opentelemetry/get-started/opentelemetry-set-up-your-app/)
