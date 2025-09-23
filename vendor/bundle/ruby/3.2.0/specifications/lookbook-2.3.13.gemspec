# -*- encoding: utf-8 -*-
# stub: lookbook 2.3.13 ruby lib

Gem::Specification.new do |s|
  s.name = "lookbook".freeze
  s.version = "2.3.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mark Perkins".freeze]
  s.date = "1980-01-02"
  s.homepage = "https://github.com/lookbook-hq/lookbook".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Lookbook is a UI development environment for Ruby on Rails applications".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<css_parser>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<activemodel>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<zeitwerk>.freeze, ["~> 2.5"])
  s.add_runtime_dependency(%q<railties>.freeze, [">= 5.0"])
  s.add_runtime_dependency(%q<view_component>.freeze, [">= 2.0"])
  s.add_runtime_dependency(%q<redcarpet>.freeze, ["~> 3.5"])
  s.add_runtime_dependency(%q<rouge>.freeze, [">= 3.26", "< 5.0"])
  s.add_runtime_dependency(%q<yard>.freeze, ["~> 0.9"])
  s.add_runtime_dependency(%q<htmlbeautifier>.freeze, ["~> 1.3"])
  s.add_runtime_dependency(%q<htmlentities>.freeze, ["~> 4.3.4"])
  s.add_runtime_dependency(%q<marcel>.freeze, ["~> 1.0"])
end
