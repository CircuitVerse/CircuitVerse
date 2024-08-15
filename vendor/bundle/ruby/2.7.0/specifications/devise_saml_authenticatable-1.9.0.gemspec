# -*- encoding: utf-8 -*-
# stub: devise_saml_authenticatable 1.9.0 ruby lib

Gem::Specification.new do |s|
  s.name = "devise_saml_authenticatable".freeze
  s.version = "1.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Josef Sauter".freeze]
  s.date = "2022-04-19"
  s.description = "SAML Authentication for devise".freeze
  s.email = ["Josef.Sauter@gmail.com".freeze]
  s.homepage = "".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "SAML Authentication for devise".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<devise>.freeze, ["> 2.0.0"])
    s.add_runtime_dependency(%q<ruby-saml>.freeze, ["~> 1.7"])
  else
    s.add_dependency(%q<devise>.freeze, ["> 2.0.0"])
    s.add_dependency(%q<ruby-saml>.freeze, ["~> 1.7"])
  end
end
