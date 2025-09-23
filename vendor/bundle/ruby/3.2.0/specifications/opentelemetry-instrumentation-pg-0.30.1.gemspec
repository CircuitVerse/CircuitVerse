# -*- encoding: utf-8 -*-
# stub: opentelemetry-instrumentation-pg 0.30.1 ruby lib

Gem::Specification.new do |s|
  s.name = "opentelemetry-instrumentation-pg".freeze
  s.version = "0.30.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/open-telemetry/opentelemetry-ruby-contrib/issues", "changelog_uri" => "https://rubydoc.info/gems/opentelemetry-instrumentation-pg/0.30.1/file/CHANGELOG.md", "documentation_uri" => "https://rubydoc.info/gems/opentelemetry-instrumentation-pg/0.30.1", "source_code_uri" => "https://github.com/open-telemetry/opentelemetry-ruby-contrib/tree/main/instrumentation/pg" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["OpenTelemetry Authors".freeze]
  s.date = "2025-04-16"
  s.description = "PG (PostgreSQL) instrumentation for the OpenTelemetry framework".freeze
  s.email = ["cncf-opentelemetry-contributors@lists.cncf.io".freeze]
  s.homepage = "https://github.com/open-telemetry/opentelemetry-ruby-contrib".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "PG (PostgreSQL) instrumentation for the OpenTelemetry framework".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<opentelemetry-api>.freeze, ["~> 1.0"])
  s.add_runtime_dependency(%q<opentelemetry-helpers-sql>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<opentelemetry-helpers-sql-obfuscation>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<opentelemetry-instrumentation-base>.freeze, ["~> 0.23.0"])
end
