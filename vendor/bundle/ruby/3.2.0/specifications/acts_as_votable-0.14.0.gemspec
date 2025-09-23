# -*- encoding: utf-8 -*-
# stub: acts_as_votable 0.14.0 ruby lib

Gem::Specification.new do |s|
  s.name = "acts_as_votable".freeze
  s.version = "0.14.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ryan".freeze]
  s.date = "2022-10-19"
  s.description = "Rails gem to allowing records to be votable".freeze
  s.email = ["ryanto".freeze]
  s.homepage = "http://rubygems.org/gems/acts_as_votable".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Rails gem to allowing records to be votable".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.6"])
  s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.3.6"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.49.1"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.15.0"])
  s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.2"])
  s.add_development_dependency(%q<factory_bot>.freeze, ["~> 4.8"])
end
