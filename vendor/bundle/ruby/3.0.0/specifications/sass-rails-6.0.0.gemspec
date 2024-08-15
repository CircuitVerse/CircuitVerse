# -*- encoding: utf-8 -*-
# stub: sass-rails 6.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "sass-rails".freeze
  s.version = "6.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["wycats".freeze, "chriseppstein".freeze]
  s.date = "2019-08-16"
  s.description = "Sass adapter for the Rails asset pipeline.".freeze
  s.email = ["wycats@gmail.com".freeze, "chris@eppsteins.net".freeze]
  s.homepage = "https://github.com/rails/sass-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.32".freeze
  s.summary = "Sass adapter for the Rails asset pipeline.".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<sassc-rails>.freeze, ["~> 2.1", ">= 2.1.1"])
  else
    s.add_dependency(%q<sassc-rails>.freeze, ["~> 2.1", ">= 2.1.1"])
  end
end
