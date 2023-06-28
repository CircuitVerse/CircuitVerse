# -*- encoding: utf-8 -*-
# stub: terser 1.1.9 ruby lib

Gem::Specification.new do |s|
  s.name = "terser".freeze
  s.version = "1.1.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Pavel Rosicky".freeze]
  s.date = "2022-05-04"
  s.description = "Terser minifies JavaScript files by wrapping     TerserJS to be accessible in Ruby".freeze
  s.email = ["pdahorek@seznam.cz".freeze]
  s.extra_rdoc_files = ["LICENSE.txt".freeze, "README.md".freeze, "CHANGELOG.md".freeze, "CONTRIBUTING.md".freeze]
  s.files = ["CHANGELOG.md".freeze, "CONTRIBUTING.md".freeze, "LICENSE.txt".freeze, "README.md".freeze]
  s.homepage = "http://github.com/ahorek/terser-ruby".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.2.32".freeze
  s.summary = "Ruby wrapper for Terser JavaScript compressor".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<execjs>.freeze, [">= 0.3.0", "< 3"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 1.3"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 12.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<sourcemap>.freeze, ["~> 0.1.1"])
  else
    s.add_dependency(%q<execjs>.freeze, [">= 0.3.0", "< 3"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.3"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<sourcemap>.freeze, ["~> 0.1.1"])
  end
end
