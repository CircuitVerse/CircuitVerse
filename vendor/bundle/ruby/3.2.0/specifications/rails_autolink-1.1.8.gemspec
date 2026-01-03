# -*- encoding: utf-8 -*-
# stub: rails_autolink 1.1.8 ruby lib

Gem::Specification.new do |s|
  s.name = "rails_autolink".freeze
  s.version = "1.1.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Aaron Patterson".freeze, "Juanjo Bazan".freeze, "Akira Matsuda".freeze]
  s.date = "2023-02-15"
  s.description = "This is an extraction of the `auto_link` method from rails. The `auto_link` method was removed from Rails in version Rails 3.1. This gem is meant to bridge the gap for people migrating.".freeze
  s.email = "aaron@tenderlovemaking.com".freeze
  s.homepage = "https://github.com/tenderlove/rails_autolink".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "Automatic generation of html links in texts".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<actionview>.freeze, ["> 3.1"])
  s.add_runtime_dependency(%q<activesupport>.freeze, ["> 3.1"])
  s.add_runtime_dependency(%q<railties>.freeze, ["> 3.1"])
end
