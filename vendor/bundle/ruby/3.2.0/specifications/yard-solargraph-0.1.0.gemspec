# -*- encoding: utf-8 -*-
# stub: yard-solargraph 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "yard-solargraph".freeze
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "https://solargraph.org", "source_code_uri" => "https://github.com/castwide/yard-solargraph" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Fred Snyder".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-02-26"
  s.email = ["fsnyder@castwide.com".freeze]
  s.homepage = "https://solargraph.org".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "A YARD extension for documenting Solargraph tags.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<yard>.freeze, ["~> 0.9"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.2"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.14"])
end
