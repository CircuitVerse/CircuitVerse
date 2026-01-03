# -*- encoding: utf-8 -*-
# stub: imagen 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "imagen".freeze
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jan Grodowski".freeze]
  s.bindir = "exe".freeze
  s.date = "2024-08-25"
  s.email = ["jgrodowski@gmail.com".freeze]
  s.homepage = "https://github.com/grodowski/imagen_rb".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "Codebase as structure of locatable classes and methods based on the Ruby AST".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<parser>.freeze, [">= 2.5", "!= 2.5.1.1"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.0.0"])
  s.add_development_dependency(%q<pry>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov-lcov>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov-html>.freeze, [">= 0"])
end
