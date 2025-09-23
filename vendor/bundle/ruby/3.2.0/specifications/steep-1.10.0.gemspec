# -*- encoding: utf-8 -*-
# stub: steep 1.10.0 ruby lib

Gem::Specification.new do |s|
  s.name = "steep".freeze
  s.version = "1.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/soutaro/steep/blob/master/CHANGELOG.md", "homepage_uri" => "https://github.com/soutaro/steep", "source_code_uri" => "https://github.com/soutaro/steep" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Soutaro Matsumoto".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-03-18"
  s.description = "Gradual Typing for Ruby".freeze
  s.email = ["matsumoto@soutaro.com".freeze]
  s.executables = ["steep".freeze]
  s.files = ["exe/steep".freeze]
  s.homepage = "https://github.com/soutaro/steep".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Gradual Typing for Ruby".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<parser>.freeze, [">= 3.1"])
  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.1"])
  s.add_runtime_dependency(%q<rainbow>.freeze, [">= 2.2.2", "< 4.0"])
  s.add_runtime_dependency(%q<listen>.freeze, ["~> 3.0"])
  s.add_runtime_dependency(%q<language_server-protocol>.freeze, [">= 3.17.0.4", "< 4.0"])
  s.add_runtime_dependency(%q<rbs>.freeze, ["~> 3.9"])
  s.add_runtime_dependency(%q<concurrent-ruby>.freeze, [">= 1.1.10"])
  s.add_runtime_dependency(%q<terminal-table>.freeze, [">= 2", "< 5"])
  s.add_runtime_dependency(%q<securerandom>.freeze, [">= 0.1"])
  s.add_runtime_dependency(%q<json>.freeze, [">= 2.1.0"])
  s.add_runtime_dependency(%q<logger>.freeze, [">= 1.3.0"])
  s.add_runtime_dependency(%q<fileutils>.freeze, [">= 1.1.0"])
  s.add_runtime_dependency(%q<strscan>.freeze, [">= 1.0.0"])
  s.add_runtime_dependency(%q<csv>.freeze, [">= 3.0.9"])
  s.add_runtime_dependency(%q<uri>.freeze, [">= 0.12.0"])
  s.add_runtime_dependency(%q<mutex_m>.freeze, [">= 0.3.0"])
end
