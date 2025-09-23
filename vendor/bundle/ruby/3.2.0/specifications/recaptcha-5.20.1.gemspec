# -*- encoding: utf-8 -*-
# stub: recaptcha 5.20.1 ruby lib

Gem::Specification.new do |s|
  s.name = "recaptcha".freeze
  s.version = "5.20.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "source_code_uri" => "https://github.com/ambethia/recaptcha" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jason L Perry".freeze]
  s.date = "2025-07-21"
  s.description = "Helpers for the reCAPTCHA API".freeze
  s.email = ["jasper@ambethia.com".freeze]
  s.homepage = "http://github.com/ambethia/recaptcha".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Helpers for the reCAPTCHA API".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<mocha>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<i18n>.freeze, [">= 0"])
  s.add_development_dependency(%q<maxitest>.freeze, [">= 0"])
  s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0"])
  s.add_development_dependency(%q<bump>.freeze, [">= 0"])
  s.add_development_dependency(%q<webmock>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
end
