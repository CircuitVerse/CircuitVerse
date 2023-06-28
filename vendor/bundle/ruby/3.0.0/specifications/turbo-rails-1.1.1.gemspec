# -*- encoding: utf-8 -*-
# stub: turbo-rails 1.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "turbo-rails".freeze
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Sam Stephenson".freeze, "Javan Mahkmali".freeze, "David Heinemeier Hansson".freeze]
  s.date = "2022-05-23"
  s.email = "david@loudthinking.com".freeze
  s.homepage = "https://github.com/hotwired/turbo-rails".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.2.32".freeze
  s.summary = "The speed of a single-page web application without having to write any JavaScript.".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activejob>.freeze, [">= 6.0.0"])
    s.add_runtime_dependency(%q<actionpack>.freeze, [">= 6.0.0"])
    s.add_runtime_dependency(%q<railties>.freeze, [">= 6.0.0"])
  else
    s.add_dependency(%q<activejob>.freeze, [">= 6.0.0"])
    s.add_dependency(%q<actionpack>.freeze, [">= 6.0.0"])
    s.add_dependency(%q<railties>.freeze, [">= 6.0.0"])
  end
end
