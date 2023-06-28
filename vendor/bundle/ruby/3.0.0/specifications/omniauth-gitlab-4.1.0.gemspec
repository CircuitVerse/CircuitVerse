# -*- encoding: utf-8 -*-
# stub: omniauth-gitlab 4.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "omniauth-gitlab".freeze
  s.version = "4.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Sergey Sein".freeze]
  s.date = "2022-09-16"
  s.description = "This is the strategy for authenticating to your GitLab service".freeze
  s.email = ["linchus@gmail.com".freeze]
  s.homepage = "https://github.com/linchus/omniauth-gitlab".freeze
  s.rubygems_version = "3.2.32".freeze
  s.summary = "This is the strategy for authenticating to your GitLab service".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<omniauth>.freeze, ["~> 2.0"])
    s.add_runtime_dependency(%q<omniauth-oauth2>.freeze, ["~> 1.8.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.1"])
    s.add_development_dependency(%q<rspec-its>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 12.0"])
  else
    s.add_dependency(%q<omniauth>.freeze, ["~> 2.0"])
    s.add_dependency(%q<omniauth-oauth2>.freeze, ["~> 1.8.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.1"])
    s.add_dependency(%q<rspec-its>.freeze, ["~> 1.0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 12.0"])
  end
end
