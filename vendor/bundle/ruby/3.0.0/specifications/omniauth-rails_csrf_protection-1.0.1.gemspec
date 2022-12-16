# -*- encoding: utf-8 -*-
# stub: omniauth-rails_csrf_protection 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "omniauth-rails_csrf_protection".freeze
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Cookpad Inc.".freeze]
  s.date = "2022-02-07"
  s.description = "This gem provides a mitigation against CVE-2015-9284 (Cross-Site Request\nForgery on the request phrase when using OmniAuth gem with a Ruby on Rails\napplication) by implementing a CSRF token verifier that directly utilize\n`ActionController::RequestForgeryProtection` code from Rails.\n".freeze
  s.email = ["kaihatsu@cookpad.com".freeze]
  s.homepage = "https://github.com/cookpad/omniauth-rails_csrf_protection".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.5".freeze
  s.summary = "Provides CSRF protection on OmniAuth request endpoint on Rails application.".freeze

  s.installed_by_version = "3.3.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<actionpack>.freeze, [">= 4.2"])
    s.add_runtime_dependency(%q<omniauth>.freeze, ["~> 2.0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_development_dependency(%q<rails>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  else
    s.add_dependency(%q<actionpack>.freeze, [">= 4.2"])
    s.add_dependency(%q<omniauth>.freeze, ["~> 2.0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<rails>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
