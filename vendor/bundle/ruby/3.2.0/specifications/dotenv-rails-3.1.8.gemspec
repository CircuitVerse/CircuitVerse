# -*- encoding: utf-8 -*-
# stub: dotenv-rails 3.1.8 ruby lib

Gem::Specification.new do |s|
  s.name = "dotenv-rails".freeze
  s.version = "3.1.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/bkeepers/dotenv/releases", "funding_uri" => "https://github.com/sponsors/bkeepers" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Brandon Keepers".freeze]
  s.date = "2025-04-10"
  s.description = "Autoload dotenv in Rails.".freeze
  s.email = ["brandon@opensoul.org".freeze]
  s.homepage = "https://github.com/bkeepers/dotenv".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Autoload dotenv in Rails.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<dotenv>.freeze, ["= 3.1.8"])
  s.add_runtime_dependency(%q<railties>.freeze, [">= 6.1"])
  s.add_development_dependency(%q<spring>.freeze, [">= 0"])
end
