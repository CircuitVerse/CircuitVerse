# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "rsolr/version"

Gem::Specification.new do |s|
  s.name        = "rsolr"
  s.summary     = "A Ruby client for Apache Solr"
  s.description = %q{RSolr aims to provide a simple and extensible library for working with Solr}
  s.version     = RSolr::VERSION
  s.authors     = ["Antoine Latter", "Dmitry Lihachev",
                  "Lucas Souza", "Peter Kieltyka",
                  "Rob Di Marco", "Magnus Bergmark",
                  "Jonathan Rochkind", "Chris Beer",
                  "Craig Smith", "Randy Souza",
                  "Colin Steele", "Peter Kieltyka",
                  "Lorenzo Riccucci", "Mike Perham",
                  "Mat Brown", "Shairon Toledo",
                  "Matthew Rudy", "Fouad Mardini",
                  "Jeremy Hinegardner", "Nathan Witmer",
                  "Naomi Dushay",
                  "\"shima\""]
  s.email       = ["goodieboy@gmail.com"]
  s.license     = 'Apache-2.0'
  s.homepage    = "https://github.com/rsolr/rsolr"
  s.rubyforge_project = "rsolr"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.required_ruby_version      = '>= 1.9.3'
  
  s.requirements << 'Apache Solr'

  s.add_dependency 'builder', '>= 2.1.2'
  s.add_dependency 'faraday', '>= 0.9.0'

  s.add_development_dependency 'activesupport'
  s.add_development_dependency 'nokogiri', '>= 1.4.0'
  s.add_development_dependency 'rake', '>= 10.0'
  s.add_development_dependency 'rdoc', '>= 4.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'solr_wrapper'
end
