# -*- encoding: utf-8 -*-
# stub: terminal-table 4.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "terminal-table".freeze
  s.version = "4.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["TJ Holowaychuk".freeze, "Scott J. Goldman".freeze]
  s.date = "2025-01-27"
  s.email = ["tj@vision-media.ca".freeze]
  s.homepage = "https://github.com/tj/terminal-table".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Simple, feature rich ascii table generation library".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<bundler>.freeze, ["~> 2"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 3.0"])
  s.add_development_dependency(%q<pry>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<unicode-display_width>.freeze, [">= 1.1.1", "< 4"])
end
