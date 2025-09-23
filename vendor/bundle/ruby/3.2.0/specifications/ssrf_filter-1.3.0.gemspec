# -*- encoding: utf-8 -*-
# stub: ssrf_filter 1.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "ssrf_filter".freeze
  s.version = "1.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/arkadiyt/ssrf_filter/blob/main/CHANGELOG.md", "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Arkadiy Tetelman".freeze]
  s.date = "2025-05-10"
  s.description = "A gem that makes it easy to prevent server side request forgery (SSRF) attacks".freeze
  s.homepage = "https://github.com/arkadiyt/ssrf_filter".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "A gem that makes it easy to prevent server side request forgery (SSRF) attacks".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<base64>.freeze, ["~> 0.2.0"])
  s.add_development_dependency(%q<bundler-audit>.freeze, ["~> 0.9.2"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.13.0"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.68.0"])
  s.add_development_dependency(%q<rubocop-rspec>.freeze, ["~> 3.2.0"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.22.0"])
  s.add_development_dependency(%q<simplecov-lcov>.freeze, ["~> 0.8.0"])
  s.add_development_dependency(%q<webmock>.freeze, [">= 3.24.0"])
  s.add_development_dependency(%q<webrick>.freeze, [">= 0"])
end
