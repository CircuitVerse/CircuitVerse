# -*- encoding: utf-8 -*-
# stub: strong_migrations 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "strong_migrations".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andrew Kane".freeze, "Bob Remeika".freeze, "David Waller".freeze]
  s.date = "2022-03-21"
  s.email = ["andrew@ankane.org".freeze, "bob.remeika@gmail.com".freeze]
  s.homepage = "https://github.com/ankane/strong_migrations".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.2.32".freeze
  s.summary = "Catch unsafe migrations in development".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activerecord>.freeze, [">= 5.2"])
  else
    s.add_dependency(%q<activerecord>.freeze, [">= 5.2"])
  end
end
