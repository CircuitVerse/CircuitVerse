# -*- encoding: utf-8 -*-
# stub: terrapin 1.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "terrapin".freeze
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jon Yurek".freeze]
  s.date = "1980-01-02"
  s.description = "Run shell commands safely, even with user-supplied values".freeze
  s.email = "jyurek@thoughtbot.com".freeze
  s.homepage = "https://github.com/thoughtbot/terrapin".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Run shell commands safely, even with user-supplied values".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<climate_control>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<activesupport>.freeze, [">= 3.0.0", "< 5.0"])
  s.add_development_dependency(%q<pry>.freeze, [">= 0"])
  s.add_development_dependency(%q<logger>.freeze, [">= 0"])
end
