# -*- encoding: utf-8 -*-
# stub: devise_saml_authenticatable 2.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "devise_saml_authenticatable".freeze
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Josef Sauter".freeze]
  s.date = "2025-04-24"
  s.description = "SAML Authentication for devise".freeze
  s.email = ["Josef.Sauter@gmail.com".freeze]
  s.homepage = "https://github.com/apokalipto/devise_saml_authenticatable".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "SAML Authentication for devise".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<devise>.freeze, ["> 2.0.0"])
  s.add_runtime_dependency(%q<ruby-saml>.freeze, ["~> 1.18"])
end
