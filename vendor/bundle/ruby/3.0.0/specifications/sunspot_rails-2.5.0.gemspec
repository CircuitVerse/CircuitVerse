# -*- encoding: utf-8 -*-
# stub: sunspot_rails 2.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "sunspot_rails".freeze
  s.version = "2.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mat Brown".freeze, "Peer Allan".freeze, "Dmitriy Dzema".freeze, "Benjamin Krause".freeze, "Marcel de Graaf".freeze, "Brandon Keepers".freeze, "Peter Berkenbosch".freeze, "Brian Atkinson".freeze, "Tom Coleman".freeze, "Matt Mitchell".freeze, "Nathan Beyer".freeze, "Kieran Topping".freeze, "Nicolas Braem".freeze, "Jeremy Ashkenas".freeze, "Dylan Vaughn".freeze, "Brian Durand".freeze, "Sam Granieri".freeze, "Nick Zadrozny".freeze, "Jason Ronallo".freeze]
  s.date = "2019-07-12"
  s.description = "    Sunspot::Rails is an extension to the Sunspot library for Solr search.\n    Sunspot::Rails adds integration between Sunspot and ActiveRecord, including\n    defining search and indexing related methods on ActiveRecord models themselves,\n    running a Sunspot-compatible Solr instance for development and test\n    environments, and automatically commit Solr index changes at the end of each\n    Rails request.\n".freeze
  s.email = ["mat@patch.com".freeze]
  s.homepage = "http://github.com/sunspot/sunspot/tree/master/sunspot_rails".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--webcvs=http://github.com/outoftime/sunspot/tree/master/%s".freeze, "--title".freeze, "Sunspot-Rails - Rails integration for the Sunspot Solr search library - API Documentation".freeze, "--main".freeze, "README.rdoc".freeze]
  s.rubygems_version = "3.2.32".freeze
  s.summary = "Rails integration for the Sunspot Solr search library".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rails>.freeze, [">= 3"])
    s.add_runtime_dependency(%q<sunspot>.freeze, ["= 2.5.0"])
    s.add_development_dependency(%q<appraisal>.freeze, ["= 2.2.0"])
    s.add_development_dependency(%q<rake>.freeze, ["< 12.3"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.7"])
    s.add_development_dependency(%q<rspec-rails>.freeze, ["~> 3.7"])
    s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.3.0"])
  else
    s.add_dependency(%q<rails>.freeze, [">= 3"])
    s.add_dependency(%q<sunspot>.freeze, ["= 2.5.0"])
    s.add_dependency(%q<appraisal>.freeze, ["= 2.2.0"])
    s.add_dependency(%q<rake>.freeze, ["< 12.3"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.7"])
    s.add_dependency(%q<rspec-rails>.freeze, ["~> 3.7"])
    s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3.0"])
  end
end
