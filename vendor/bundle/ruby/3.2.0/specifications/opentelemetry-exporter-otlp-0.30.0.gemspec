# -*- encoding: utf-8 -*-
# stub: opentelemetry-exporter-otlp 0.30.0 ruby lib

Gem::Specification.new do |s|
  s.name = "opentelemetry-exporter-otlp".freeze
  s.version = "0.30.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/open-telemetry/opentelemetry-ruby/issues", "changelog_uri" => "https://open-telemetry.github.io/opentelemetry-ruby/opentelemetry-exporter-otlp/v0.30.0/file.CHANGELOG.html", "documentation_uri" => "https://open-telemetry.github.io/opentelemetry-ruby/opentelemetry-exporter-otlp/v0.30.0", "source_code_uri" => "https://github.com/open-telemetry/opentelemetry-ruby/tree/main/exporter/otlp" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["OpenTelemetry Authors".freeze]
  s.date = "2025-02-25"
  s.description = "OTLP exporter for the OpenTelemetry framework".freeze
  s.email = ["cncf-opentelemetry-contributors@lists.cncf.io".freeze]
  s.homepage = "https://github.com/open-telemetry/opentelemetry-ruby".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "OTLP exporter for the OpenTelemetry framework".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<googleapis-common-protos-types>.freeze, ["~> 1.3"])
  s.add_runtime_dependency(%q<google-protobuf>.freeze, [">= 3.18"])
  s.add_runtime_dependency(%q<opentelemetry-api>.freeze, ["~> 1.1"])
  s.add_runtime_dependency(%q<opentelemetry-common>.freeze, ["~> 0.20"])
  s.add_runtime_dependency(%q<opentelemetry-sdk>.freeze, ["~> 1.2"])
  s.add_runtime_dependency(%q<opentelemetry-semantic_conventions>.freeze, [">= 0"])
  s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.2.0"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 1.17"])
  s.add_development_dependency(%q<faraday>.freeze, ["~> 0.13"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
  s.add_development_dependency(%q<opentelemetry-test-helpers>.freeze, [">= 0"])
  s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 12.0"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.65"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.17"])
  s.add_development_dependency(%q<webmock>.freeze, ["~> 3.24"])
  s.add_development_dependency(%q<yard>.freeze, ["~> 0.9"])
  s.add_development_dependency(%q<yard-doctest>.freeze, ["~> 0.1.6"])
end
