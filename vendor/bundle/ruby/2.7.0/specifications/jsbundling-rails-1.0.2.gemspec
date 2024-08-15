# -*- encoding: utf-8 -*-
# stub: jsbundling-rails 1.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "jsbundling-rails".freeze
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2022-02-26"
  s.email = "david@loudthinking.com".freeze
  s.homepage = "https://github.com/rails/jsbundling-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Bundle and transpile JavaScript in Rails with esbuild, rollup.js, or Webpack.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<railties>.freeze, [">= 6.0.0"])
  else
    s.add_dependency(%q<railties>.freeze, [">= 6.0.0"])
  end
end
