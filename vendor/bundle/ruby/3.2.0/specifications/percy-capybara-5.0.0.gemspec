# -*- encoding: utf-8 -*-
# stub: percy-capybara 5.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "percy-capybara".freeze
  s.version = "5.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/percy/percy-capybara/issues", "source_code_uri" => "https://github.com/percy/percy-capybara" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Perceptual Inc.".freeze]
  s.date = "2021-07-15"
  s.description = "".freeze
  s.email = ["team@percy.io".freeze]
  s.homepage = "".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "Percy visual testing for Capybara".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<capybara>.freeze, [">= 3"])
  s.add_development_dependency(%q<selenium-webdriver>.freeze, [">= 4.0.0.beta1"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 2.0"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5"])
  s.add_development_dependency(%q<capybara>.freeze, ["~> 3.31"])
  s.add_development_dependency(%q<percy-style>.freeze, ["~> 0.7.0"])
end
