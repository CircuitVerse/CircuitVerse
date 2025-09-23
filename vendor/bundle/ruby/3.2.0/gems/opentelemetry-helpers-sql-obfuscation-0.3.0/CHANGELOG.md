# Release History: opentelemetry-helpers-sql-obfuscation

### v0.3.0 / 2025-01-16

* BREAKING CHANGE: Set minimum supported version to Ruby 3.1

* ADDED: Set minimum supported version to Ruby 3.1

### v0.2.1 / 2024-11-26

* (No significant changes)

### v0.2.0 / 2024-09-12

- BREAKING CHANGE: Return message when sql is over the obfuscation limit. Fixes a bug where sql statements with prepended comments that hit the obfuscation limit would be sent raw.

### v0.1.1 / 2024-06-18

- FIXED: Relax otel common gem constraints

### v0.1.0 / 2024-02-08

Initial release.
