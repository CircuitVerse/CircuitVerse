# -*- encoding: utf-8 -*-
# stub: ffi-compiler 1.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "ffi-compiler".freeze
  s.version = "1.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Wayne Meissner".freeze]
  s.date = "2024-03-14"
  s.description = "Ruby FFI library".freeze
  s.email = ["wmeissner@gmail.com".freeze, "steve@advancedcontrol.com.au".freeze]
  s.homepage = "https://github.com/ffi/ffi-compiler".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "Ruby FFI Rakefile generator".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rake>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<ffi>.freeze, [">= 1.15.5"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubygems-tasks>.freeze, [">= 0"])
end
