# -*- encoding: utf-8 -*-
# stub: nested_form 0.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "nested_form".freeze
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.4".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ryan Bates".freeze, "Andrea Singh".freeze]
  s.date = "2013-04-05"
  s.description = "Gem to conveniently handle multiple models in a single form with Rails 3 and jQuery or Prototype.".freeze
  s.email = "ryan@railscasts.com".freeze
  s.homepage = "http://github.com/ryanb/nested_form".freeze
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Gem to conveniently handle multiple models in a single form.".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec-rails>.freeze, ["~> 2.6"])
    s.add_development_dependency(%q<mocha>.freeze, [">= 0"])
    s.add_development_dependency(%q<capybara>.freeze, ["~> 1.1"])
  else
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rspec-rails>.freeze, ["~> 2.6"])
    s.add_dependency(%q<mocha>.freeze, [">= 0"])
    s.add_dependency(%q<capybara>.freeze, ["~> 1.1"])
  end
end
