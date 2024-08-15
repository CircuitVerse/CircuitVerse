# -*- encoding: utf-8 -*-
# stub: commontator 7.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "commontator".freeze
  s.version = "7.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Dante Soares".freeze]
  s.date = "2022-01-17"
  s.description = "A Rails engine for comments.".freeze
  s.email = ["dante.m.soares@rice.edu".freeze]
  s.homepage = "https://github.com/lml/commontator".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Allows users to comment on any model in your application.".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rails>.freeze, [">= 6.0"])
    s.add_runtime_dependency(%q<sprockets-rails>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<will_paginate>.freeze, [">= 0"])
    s.add_development_dependency(%q<jquery-rails>.freeze, [">= 0"])
    s.add_development_dependency(%q<sassc-rails>.freeze, [">= 0"])
    s.add_development_dependency(%q<rails-i18n>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec-rails>.freeze, [">= 0"])
    s.add_development_dependency(%q<rails-controller-testing>.freeze, [">= 0"])
    s.add_development_dependency(%q<listen>.freeze, [">= 0"])
    s.add_development_dependency(%q<acts_as_votable>.freeze, [">= 0"])
    s.add_development_dependency(%q<mailgun_rails>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rails>.freeze, [">= 6.0"])
    s.add_dependency(%q<sprockets-rails>.freeze, [">= 0"])
    s.add_dependency(%q<will_paginate>.freeze, [">= 0"])
    s.add_dependency(%q<jquery-rails>.freeze, [">= 0"])
    s.add_dependency(%q<sassc-rails>.freeze, [">= 0"])
    s.add_dependency(%q<rails-i18n>.freeze, [">= 0"])
    s.add_dependency(%q<rspec-rails>.freeze, [">= 0"])
    s.add_dependency(%q<rails-controller-testing>.freeze, [">= 0"])
    s.add_dependency(%q<listen>.freeze, [">= 0"])
    s.add_dependency(%q<acts_as_votable>.freeze, [">= 0"])
    s.add_dependency(%q<mailgun_rails>.freeze, [">= 0"])
  end
end
