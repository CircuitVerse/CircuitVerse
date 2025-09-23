# -*- encoding: utf-8 -*-
# stub: pp 0.6.2 ruby lib

Gem::Specification.new do |s|
  s.name = "pp".freeze
  s.version = "0.6.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "https://github.com/ruby/pp", "source_code_uri" => "https://github.com/ruby/pp" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tanaka Akira".freeze]
  s.bindir = "exe".freeze
  s.date = "2024-12-03"
  s.description = "Provides a PrettyPrinter for Ruby objects".freeze
  s.email = ["akr@fsij.org".freeze]
  s.homepage = "https://github.com/ruby/pp".freeze
  s.licenses = ["Ruby".freeze, "BSD-2-Clause".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Provides a PrettyPrinter for Ruby objects".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<prettyprint>.freeze, [">= 0"])
end
