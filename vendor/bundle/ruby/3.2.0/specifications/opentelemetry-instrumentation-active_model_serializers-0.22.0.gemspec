# -*- encoding: utf-8 -*-
# stub: opentelemetry-instrumentation-active_model_serializers 0.22.0 ruby lib

Gem::Specification.new do |s|
  s.name = "opentelemetry-instrumentation-active_model_serializers".freeze
  s.version = "0.22.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/open-telemetry/opentelemetry-ruby-contrib/issues", "changelog_uri" => "https://rubydoc.info/gems/opentelemetry-instrumentation-active_model_serializers/0.22.0/file/CHANGELOG.md", "documentation_uri" => "https://rubydoc.info/gems/opentelemetry-instrumentation-active_model_serializers/0.22.0", "source_code_uri" => "https://github.com/open-telemetry/opentelemetry-ruby-contrib/tree/main/instrumentation/active_model_serializers" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["OpenTelemetry Authors".freeze]
  s.date = "2025-01-16"
  s.description = "Active Model Serializers instrumentation for the OpenTelemetry framework".freeze
  s.email = ["cncf-opentelemetry-contributors@lists.cncf.io".freeze]
  s.homepage = "https://github.com/open-telemetry/opentelemetry-ruby-contrib".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "Active Model Serializers instrumentation for the OpenTelemetry framework".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<opentelemetry-api>.freeze, ["~> 1.0"])
  s.add_runtime_dependency(%q<opentelemetry-instrumentation-active_support>.freeze, [">= 0.7.0"])
  s.add_runtime_dependency(%q<opentelemetry-instrumentation-base>.freeze, ["~> 0.23.0"])
  s.add_development_dependency(%q<active_model_serializers>.freeze, [">= 0.10.0"])
  s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.5"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 2.4"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
  s.add_development_dependency(%q<opentelemetry-sdk>.freeze, ["~> 1.1"])
  s.add_development_dependency(%q<opentelemetry-test-helpers>.freeze, ["~> 0.3"])
  s.add_development_dependency(%q<rspec-mocks>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.69.1"])
  s.add_development_dependency(%q<rubocop-performance>.freeze, ["~> 1.23.0"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.17.1"])
  s.add_development_dependency(%q<webmock>.freeze, ["~> 3.24.0"])
  s.add_development_dependency(%q<yard>.freeze, ["~> 0.9"])
end
