# -*- encoding: utf-8 -*-
# stub: undercover 0.8.0 ruby lib

Gem::Specification.new do |s|
  s.name = "undercover".freeze
  s.version = "0.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jan Grodowski".freeze]
  s.date = "2025-08-28"
  s.email = ["jgrodowski@gmail.com".freeze]
  s.executables = ["undercover".freeze]
  s.files = ["bin/undercover".freeze]
  s.homepage = "https://github.com/grodowski/undercover".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Actionable code coverage - detects untested code blocks in recent changes".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<base64>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<bigdecimal>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<imagen>.freeze, [">= 0.2.0"])
  s.add_runtime_dependency(%q<rainbow>.freeze, [">= 2.1", "< 4.0"])
  s.add_runtime_dependency(%q<rugged>.freeze, [">= 0.27", "< 1.10"])
  s.add_runtime_dependency(%q<simplecov>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<simplecov_json_formatter>.freeze, [">= 0"])
end
