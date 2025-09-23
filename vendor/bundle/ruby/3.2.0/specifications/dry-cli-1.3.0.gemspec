# -*- encoding: utf-8 -*-
# stub: dry-cli 1.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "dry-cli".freeze
  s.version = "1.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "bug_tracker_uri" => "https://github.com/dry-rb/dry-cli/issues", "changelog_uri" => "https://github.com/dry-rb/dry-cli/blob/main/CHANGELOG.md", "source_code_uri" => "https://github.com/dry-rb/dry-cli" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Luca Guidi".freeze]
  s.date = "2025-07-29"
  s.description = "Common framework to build command line interfaces with Ruby".freeze
  s.email = ["me@lucaguidi.com".freeze]
  s.homepage = "https://dry-rb.org/gems/dry-cli".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Common framework to build command line interfaces with Ruby".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<bundler>.freeze, [">= 1.6", "< 3"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.7"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.17.1"])
end
