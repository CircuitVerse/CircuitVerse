# -*- encoding: utf-8 -*-
# stub: font-awesome-sass 5.13.1 ruby lib

Gem::Specification.new do |s|
  s.name = "font-awesome-sass".freeze
  s.version = "5.13.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Travis Chase".freeze]
  s.date = "2020-10-18"
  s.description = "Font-Awesome SASS gem for use in Ruby projects".freeze
  s.email = ["travis@fontawesome.com".freeze]
  s.homepage = "https://github.com/FortAwesome/font-awesome-sass".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Font-Awesome SASS".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<sassc>.freeze, [">= 1.11"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 1.3"])
    s.add_development_dependency(%q<compass>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  else
    s.add_dependency(%q<sassc>.freeze, [">= 1.11"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.3"])
    s.add_dependency(%q<compass>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
