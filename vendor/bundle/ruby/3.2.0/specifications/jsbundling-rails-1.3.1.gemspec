# -*- encoding: utf-8 -*-
# stub: jsbundling-rails 1.3.1 ruby lib

Gem::Specification.new do |s|
  s.name = "jsbundling-rails".freeze
  s.version = "1.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/rails/jsbundling-rails/releases" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2024-07-29"
  s.email = "david@loudthinking.com".freeze
  s.homepage = "https://github.com/rails/jsbundling-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Bundle and transpile JavaScript in Rails with bun, esbuild, rollup.js, or Webpack.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<railties>.freeze, [">= 6.0.0"])
end
