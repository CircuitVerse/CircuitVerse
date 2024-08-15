# -*- encoding: utf-8 -*-
# stub: simple_discussion 1.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "simple_discussion".freeze
  s.version = "1.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Chris Oliver".freeze]
  s.bindir = "exe".freeze
  s.date = "2021-03-31"
  s.description = "A simple, extensible Rails forum".freeze
  s.email = ["excid3@gmail.com".freeze]
  s.homepage = "https://github.com/excid3/simple_discussion".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.32".freeze
  s.summary = "A simple, extensible Rails forum".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<font-awesome-sass>.freeze, [">= 5.13.0"])
    s.add_runtime_dependency(%q<friendly_id>.freeze, [">= 5.2.0"])
    s.add_runtime_dependency(%q<rails>.freeze, [">= 4.2"])
    s.add_runtime_dependency(%q<will_paginate>.freeze, [">= 3.1.0"])
  else
    s.add_dependency(%q<font-awesome-sass>.freeze, [">= 5.13.0"])
    s.add_dependency(%q<friendly_id>.freeze, [">= 5.2.0"])
    s.add_dependency(%q<rails>.freeze, [">= 4.2"])
    s.add_dependency(%q<will_paginate>.freeze, [">= 3.1.0"])
  end
end
