# -*- encoding: utf-8 -*-
# stub: omniauth-google-oauth2 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "omniauth-google-oauth2".freeze
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Josh Ellithorpe".freeze, "Yury Korolev".freeze]
  s.date = "2022-03-11"
  s.description = "A Google OAuth2 strategy for OmniAuth 1.x. This allows you to login to Google with your ruby app.".freeze
  s.email = ["quest@mac.com".freeze]
  s.homepage = "https://github.com/zquestz/omniauth-google-oauth2".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2".freeze)
  s.rubygems_version = "3.3.7".freeze
  s.summary = "A Google OAuth2 strategy for OmniAuth 1.x".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<jwt>.freeze, [">= 2.0"])
    s.add_runtime_dependency(%q<oauth2>.freeze, ["~> 1.1"])
    s.add_runtime_dependency(%q<omniauth>.freeze, ["~> 2.0"])
    s.add_runtime_dependency(%q<omniauth-oauth2>.freeze, ["~> 1.7.1"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 12.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.6"])
    s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.49"])
  else
    s.add_dependency(%q<jwt>.freeze, [">= 2.0"])
    s.add_dependency(%q<oauth2>.freeze, ["~> 1.1"])
    s.add_dependency(%q<omniauth>.freeze, ["~> 2.0"])
    s.add_dependency(%q<omniauth-oauth2>.freeze, ["~> 1.7.1"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.6"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.49"])
  end
end
