# -*- encoding: utf-8 -*-
# stub: device_detector 1.0.7 ruby lib

Gem::Specification.new do |s|
  s.name = "device_detector".freeze
  s.version = "1.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mati S\u00F3jka".freeze, "Ben Zimmer".freeze]
  s.date = "2022-02-21"
  s.description = "Precise and fast user agent parser and device detector, backed by the largest and most up-to-date agent and device database".freeze
  s.email = ["yagooar@gmail.com".freeze]
  s.homepage = "http://podigee.github.io/device_detector".freeze
  s.licenses = ["LGPL-3.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Precise and fast user agent parser and device detector".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<pry>.freeze, [">= 0.10"])
    s.add_development_dependency(%q<rubocop>.freeze, ["= 0.85.1"])
  else
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<pry>.freeze, [">= 0.10"])
    s.add_dependency(%q<rubocop>.freeze, ["= 0.85.1"])
  end
end
