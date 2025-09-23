# -*- encoding: utf-8 -*-
# stub: maintenance_tasks 2.12.0 ruby lib

Gem::Specification.new do |s|
  s.name = "maintenance_tasks".freeze
  s.version = "2.12.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "source_code_uri" => "https://github.com/Shopify/maintenance_tasks/tree/v2.12.0" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Shopify Engineering".freeze]
  s.bindir = "exe".freeze
  s.date = "1980-01-02"
  s.email = "gems@shopify.com".freeze
  s.executables = ["maintenance_tasks".freeze]
  s.files = ["exe/maintenance_tasks".freeze]
  s.homepage = "https://github.com/Shopify/maintenance_tasks".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "A Rails engine for queuing and managing maintenance tasks".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<actionpack>.freeze, [">= 7.0"])
  s.add_runtime_dependency(%q<activejob>.freeze, [">= 7.0"])
  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 7.0"])
  s.add_runtime_dependency(%q<csv>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<job-iteration>.freeze, [">= 1.3.6"])
  s.add_runtime_dependency(%q<railties>.freeze, [">= 7.0"])
  s.add_runtime_dependency(%q<zeitwerk>.freeze, [">= 2.6.2"])
end
