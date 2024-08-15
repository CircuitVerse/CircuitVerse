# -*- encoding: utf-8 -*-
# stub: country_select 6.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "country_select".freeze
  s.version = "6.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Stefan Penner".freeze]
  s.date = "2022-01-20"
  s.description = "Provides a simple helper to get an HTML select list of countries. The list of countries comes from the ISO 3166 standard. While it is a relatively neutral source of country names, it will still offend some users.".freeze
  s.email = ["stefan.penner@gmail.com".freeze]
  s.homepage = "https://github.com/countries/country_select".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5".freeze)
  s.rubygems_version = "3.2.32".freeze
  s.summary = "Country Select Plugin".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<actionpack>.freeze, ["~> 7.0"])
    s.add_development_dependency(%q<pry>.freeze, ["~> 0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3"])
    s.add_runtime_dependency(%q<countries>.freeze, ["~> 4.2"])
    s.add_runtime_dependency(%q<sort_alphabetical>.freeze, ["~> 1.1"])
  else
    s.add_dependency(%q<actionpack>.freeze, ["~> 7.0"])
    s.add_dependency(%q<pry>.freeze, ["~> 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 13"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3"])
    s.add_dependency(%q<countries>.freeze, ["~> 4.2"])
    s.add_dependency(%q<sort_alphabetical>.freeze, ["~> 1.1"])
  end
end
