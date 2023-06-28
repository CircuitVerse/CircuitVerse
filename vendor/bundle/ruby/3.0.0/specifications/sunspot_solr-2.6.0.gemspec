# -*- encoding: utf-8 -*-
# stub: sunspot_solr 2.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "sunspot_solr".freeze
  s.version = "2.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mat Brown".freeze, "Peer Allan".freeze, "Dmitriy Dzema".freeze, "Benjamin Krause".freeze, "Marcel de Graaf".freeze, "Brandon Keepers".freeze, "Peter Berkenbosch".freeze, "Brian Atkinson".freeze, "Tom Coleman".freeze, "Matt Mitchell".freeze, "Nathan Beyer".freeze, "Kieran Topping".freeze, "Nicolas Braem".freeze, "Jeremy Ashkenas".freeze, "Dylan Vaughn".freeze, "Brian Durand".freeze, "Sam Granieri".freeze, "Nick Zadrozny".freeze, "Jason Ronallo".freeze]
  s.date = "2022-05-30"
  s.description = "    Sunspot::Solr provides a bundled Solr distribution for use with Sunspot.\n    Typical deployment environments will require more configuration, but this\n    distribution is well suited to development and testing.\n".freeze
  s.email = ["mat@patch.com".freeze]
  s.executables = ["sunspot-installer".freeze, "sunspot-solr".freeze]
  s.files = ["bin/sunspot-installer".freeze, "bin/sunspot-solr".freeze]
  s.homepage = "https://github.com/sunspot/sunspot/tree/master/sunspot_solr".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.32".freeze
  s.summary = "Bundled Solr distribution for Sunspot".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<rake>.freeze, ["< 12.3"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.7"])
  else
    s.add_dependency(%q<rake>.freeze, ["< 12.3"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.7"])
  end
end
