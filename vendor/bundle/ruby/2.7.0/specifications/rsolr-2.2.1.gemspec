# -*- encoding: utf-8 -*-
# stub: rsolr 2.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rsolr".freeze
  s.version = "2.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Antoine Latter".freeze, "Dmitry Lihachev".freeze, "Lucas Souza".freeze, "Peter Kieltyka".freeze, "Rob Di Marco".freeze, "Magnus Bergmark".freeze, "Jonathan Rochkind".freeze, "Chris Beer".freeze, "Craig Smith".freeze, "Randy Souza".freeze, "Colin Steele".freeze, "Peter Kieltyka".freeze, "Lorenzo Riccucci".freeze, "Mike Perham".freeze, "Mat Brown".freeze, "Shairon Toledo".freeze, "Matthew Rudy".freeze, "Fouad Mardini".freeze, "Jeremy Hinegardner".freeze, "Nathan Witmer".freeze, "Naomi Dushay".freeze, "\"shima\"".freeze]
  s.date = "2018-05-14"
  s.description = "RSolr aims to provide a simple and extensible library for working with Solr".freeze
  s.email = ["goodieboy@gmail.com".freeze]
  s.homepage = "https://github.com/rsolr/rsolr".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.requirements = ["Apache Solr".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "A Ruby client for Apache Solr".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<builder>.freeze, [">= 2.1.2"])
    s.add_runtime_dependency(%q<faraday>.freeze, [">= 0.9.0"])
    s.add_development_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_development_dependency(%q<nokogiri>.freeze, [">= 1.4.0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 10.0"])
    s.add_development_dependency(%q<rdoc>.freeze, [">= 4.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_development_dependency(%q<solr_wrapper>.freeze, [">= 0"])
  else
    s.add_dependency(%q<builder>.freeze, [">= 2.1.2"])
    s.add_dependency(%q<faraday>.freeze, [">= 0.9.0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<nokogiri>.freeze, [">= 1.4.0"])
    s.add_dependency(%q<rake>.freeze, [">= 10.0"])
    s.add_dependency(%q<rdoc>.freeze, [">= 4.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<solr_wrapper>.freeze, [">= 0"])
  end
end
