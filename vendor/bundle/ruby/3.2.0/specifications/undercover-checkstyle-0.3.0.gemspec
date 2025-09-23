# -*- encoding: utf-8 -*-
# stub: undercover-checkstyle 0.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "undercover-checkstyle".freeze
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "https://github.com/aki77/undercover-checkstyle", "source_code_uri" => "https://github.com/aki77/undercover-checkstyle" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["aki77".freeze]
  s.bindir = "exe".freeze
  s.date = "2021-02-15"
  s.description = "Undercover checkstyle reporter.".freeze
  s.email = ["aki77@users.noreply.github.com".freeze]
  s.executables = ["undercover-checkstyle".freeze]
  s.files = ["exe/undercover-checkstyle".freeze]
  s.homepage = "https://github.com/aki77/undercover-checkstyle".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Undercover checkstyle reporter.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<undercover>.freeze, [">= 0.3.4"])
  s.add_runtime_dependency(%q<rexml>.freeze, [">= 0"])
end
