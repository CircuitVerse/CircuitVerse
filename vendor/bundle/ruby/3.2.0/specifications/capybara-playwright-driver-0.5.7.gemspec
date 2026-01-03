# -*- encoding: utf-8 -*-
# stub: capybara-playwright-driver 0.5.7 ruby lib

Gem::Specification.new do |s|
  s.name = "capybara-playwright-driver".freeze
  s.version = "0.5.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["YusukeIwaki".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-08-05"
  s.email = ["q7w8e9w8q7w8e9@yahoo.co.jp".freeze]
  s.homepage = "https://github.com/YusukeIwaki/capybara-playwright-driver".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "Playwright driver for Capybara".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<addressable>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<capybara>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<playwright-ruby-client>.freeze, [">= 1.16.0"])
end
