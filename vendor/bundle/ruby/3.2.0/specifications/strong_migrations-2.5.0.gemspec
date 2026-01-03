# -*- encoding: utf-8 -*-
# stub: strong_migrations 2.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "strong_migrations".freeze
  s.version = "2.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andrew Kane".freeze, "Bob Remeika".freeze, "David Waller".freeze]
  s.date = "1980-01-02"
  s.email = ["andrew@ankane.org".freeze, "bob.remeika@gmail.com".freeze]
  s.homepage = "https://github.com/ankane/strong_migrations".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.2".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "Catch unsafe migrations in development".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 7.1"])
end
