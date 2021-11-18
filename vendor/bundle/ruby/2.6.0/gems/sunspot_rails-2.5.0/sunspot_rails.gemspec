# -*- encoding: utf-8 -*-
lib = File.expand_path('../../sunspot/lib/', __FILE__)

$:.unshift(lib) unless $:.include?(lib)

require 'sunspot/version'

Gem::Specification.new do |s|
  s.name        = "sunspot_rails"
  s.version     = Sunspot::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Mat Brown', 'Peer Allan', 'Dmitriy Dzema', 'Benjamin Krause', 'Marcel de Graaf', 'Brandon Keepers', 'Peter Berkenbosch',
                  'Brian Atkinson', 'Tom Coleman', 'Matt Mitchell', 'Nathan Beyer', 'Kieran Topping', 'Nicolas Braem', 'Jeremy Ashkenas',
                  'Dylan Vaughn', 'Brian Durand', 'Sam Granieri', 'Nick Zadrozny', 'Jason Ronallo']
  s.email       = ["mat@patch.com"]
  s.homepage = 'http://github.com/sunspot/sunspot/tree/master/sunspot_rails'
  s.summary     = 'Rails integration for the Sunspot Solr search library'
  s.license     = 'MIT'
  s.description = <<-TEXT
    Sunspot::Rails is an extension to the Sunspot library for Solr search.
    Sunspot::Rails adds integration between Sunspot and ActiveRecord, including
    defining search and indexing related methods on ActiveRecord models themselves,
    running a Sunspot-compatible Solr instance for development and test
    environments, and automatically commit Solr index changes at the end of each
    Rails request.
  TEXT

  s.rubyforge_project = "sunspot"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  if RUBY_VERSION < '2.2'
    s.add_dependency 'rails', '>= 3', '< 5'
  else
    s.add_dependency 'rails', '>= 3'
  end

  s.add_dependency 'sunspot', Sunspot::VERSION
  
  s.add_development_dependency 'appraisal', '2.2.0'
  s.add_development_dependency 'bundler',  '>= 1.3.0', '< 2.0' if RUBY_VERSION <= '2.0.0'
  s.add_development_dependency 'nokogiri', '< 1.7' if RUBY_VERSION <= '2.0.0'
  s.add_development_dependency 'rake', '< 12.3'
  s.add_development_dependency 'rspec', '~> 3.7'
  s.add_development_dependency 'rspec-rails', '~> 3.7'
  s.add_development_dependency 'sqlite3',  '~> 1.3.0'

  s.rdoc_options << '--webcvs=http://github.com/outoftime/sunspot/tree/master/%s' <<
                  '--title' << 'Sunspot-Rails - Rails integration for the Sunspot Solr search library - API Documentation' <<
                  '--main' << 'README.rdoc'
end
