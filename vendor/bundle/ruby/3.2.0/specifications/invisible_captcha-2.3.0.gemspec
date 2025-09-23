# -*- encoding: utf-8 -*-
# stub: invisible_captcha 2.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "invisible_captcha".freeze
  s.version = "2.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Marc Anguera Insa".freeze]
  s.date = "2024-03-17"
  s.description = "Unobtrusive, flexible and complete spam protection for Rails applications using honeypot strategy for better user experience.".freeze
  s.email = ["srmarc.ai@gmail.com".freeze]
  s.homepage = "https://github.com/markets/invisible_captcha".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Honeypot spam protection for Rails".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rails>.freeze, [">= 5.2"])
  s.add_development_dependency(%q<rspec-rails>.freeze, [">= 0"])
  s.add_development_dependency(%q<appraisal>.freeze, [">= 0"])
  s.add_development_dependency(%q<webrick>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov-cobertura>.freeze, [">= 0"])
end
