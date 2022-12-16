# -*- encoding: utf-8 -*-
# stub: acts_as_votable 0.13.2 ruby lib

Gem::Specification.new do |s|
  s.name = "acts_as_votable".freeze
  s.version = "0.13.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ryan".freeze]
  s.date = "2021-11-08"
  s.description = "Rails gem to allowing records to be votable".freeze
  s.email = ["ryanto".freeze]
  s.homepage = "http://rubygems.org/gems/acts_as_votable".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.5".freeze
  s.summary = "Rails gem to allowing records to be votable".freeze

  s.installed_by_version = "3.3.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.6"])
    s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.3.6"])
    s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.49.1"])
    s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.15.0"])
    s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.2"])
    s.add_development_dependency(%q<factory_bot>.freeze, ["~> 4.8"])
  else
    s.add_dependency(%q<rspec>.freeze, ["~> 3.6"])
    s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3.6"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.49.1"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.15.0"])
    s.add_dependency(%q<appraisal>.freeze, ["~> 2.2"])
    s.add_dependency(%q<factory_bot>.freeze, ["~> 4.8"])
  end
end
