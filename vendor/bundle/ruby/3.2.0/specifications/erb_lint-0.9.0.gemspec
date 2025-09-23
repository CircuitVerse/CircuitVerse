# -*- encoding: utf-8 -*-
# stub: erb_lint 0.9.0 ruby lib

Gem::Specification.new do |s|
  s.name = "erb_lint".freeze
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Justin Chan".freeze, "Shopify Developers".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-01-20"
  s.description = "ERB Linter tool.".freeze
  s.email = ["ruby@shopify.com".freeze]
  s.executables = ["erb_lint".freeze, "erblint".freeze]
  s.files = ["exe/erb_lint".freeze, "exe/erblint".freeze]
  s.homepage = "https://github.com/Shopify/erb_lint".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "ERB lint tool".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<better_html>.freeze, [">= 2.0.1"])
  s.add_runtime_dependency(%q<parser>.freeze, [">= 2.7.1.4"])
  s.add_runtime_dependency(%q<rainbow>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<rubocop>.freeze, [">= 1"])
  s.add_runtime_dependency(%q<smart_properties>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop-shopify>.freeze, [">= 0"])
end
