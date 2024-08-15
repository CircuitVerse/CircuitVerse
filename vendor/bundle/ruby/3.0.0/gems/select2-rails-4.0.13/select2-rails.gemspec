# -*- encoding: utf-8 -*-
require File.expand_path("../lib/select2-rails/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "select2-rails"
  s.version     = Select2::Rails::VERSION
  s.authors     = ["Rogerio Medeiros", "Pedro Nascimento"]
  s.email       = ["argerim@gmail.com", "pnascimento@gmail.com"]
  s.homepage    = "https://github.com/argerim/select2-rails"
  s.summary     = %q{Integrate Select2 javascript library with Rails asset pipeline}
  s.description = %q{Select2 is a jQuery based replacement for select boxes. It supports searching, remote data sets, and infinite scrolling of results. This gem integrates Select2 with Rails asset pipeline for easy of use.}
  s.license     = 'MIT'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "thor", "~> 1"
  s.add_development_dependency "bundler", "~> 1.0"
  s.add_development_dependency "rails", ">= 3.0"
  s.add_development_dependency "httpclient", "~> 2.2"
end
