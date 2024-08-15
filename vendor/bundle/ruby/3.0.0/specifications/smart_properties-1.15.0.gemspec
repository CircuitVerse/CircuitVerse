# -*- encoding: utf-8 -*-
# stub: smart_properties 1.15.0 ruby lib

Gem::Specification.new do |s|
  s.name = "smart_properties".freeze
  s.version = "1.15.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Konstantin Tennhard".freeze]
  s.date = "2019-07-02"
  s.description = "  SmartProperties are a more flexible and feature-rich alternative to\n  traditional Ruby accessors. They provide support for input conversion,\n  input validation, specifying default values and presence checking.\n".freeze
  s.email = ["me@t6d.de".freeze]
  s.homepage = "".freeze
  s.rubygems_version = "3.2.32".freeze
  s.summary = "SmartProperties \u2013 Ruby accessors on steroids".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_development_dependency(%q<pry>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
  end
end
