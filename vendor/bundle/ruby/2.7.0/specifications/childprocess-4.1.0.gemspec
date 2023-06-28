# -*- encoding: utf-8 -*-
# stub: childprocess 4.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "childprocess".freeze
  s.version = "4.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jari Bakken".freeze, "Eric Kessler".freeze, "Shane da Silva".freeze]
  s.date = "2021-06-09"
  s.description = "This gem aims at being a simple and reliable solution for controlling external programs running in the background on any Ruby / OS combination.".freeze
  s.email = ["morrow748@gmail.com".freeze, "shane@dasilva.io".freeze]
  s.homepage = "https://github.com/enkessler/childprocess".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "A simple and reliable solution for controlling external programs running in the background on any Ruby / OS combination.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<yard>.freeze, ["~> 0.0"])
    s.add_development_dependency(%q<coveralls>.freeze, ["< 1.0"])
  else
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<yard>.freeze, ["~> 0.0"])
    s.add_dependency(%q<coveralls>.freeze, ["< 1.0"])
  end
end
