# -*- encoding: utf-8 -*-
# stub: coveralls_reborn 0.23.1 ruby lib

Gem::Specification.new do |s|
  s.name = "coveralls_reborn".freeze
  s.version = "0.23.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/tagliala/coveralls-ruby-reborn/issues", "changelog_uri" => "https://github.com/tagliala/coveralls-ruby-reborn/blob/main/CHANGELOG.md", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/tagliala/coveralls-ruby-reborn" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nick Merwin".freeze, "Wil Gieseler".freeze, "Geremia Taglialatela".freeze]
  s.date = "2021-11-15"
  s.description = "A Ruby implementation of the Coveralls API.".freeze
  s.email = ["nick@lemurheavy.com".freeze, "supapuerco@gmail.com".freeze, "tagliala.dev@gmail.com".freeze]
  s.executables = ["coveralls".freeze]
  s.files = ["bin/coveralls".freeze]
  s.homepage = "https://coveralls.io".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5".freeze)
  s.rubygems_version = "3.2.32".freeze
  s.summary = "A Ruby implementation of the Coveralls API.".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<simplecov>.freeze, [">= 0.18.1", "< 0.22.0"])
    s.add_runtime_dependency(%q<term-ansicolor>.freeze, ["~> 1.6"])
    s.add_runtime_dependency(%q<thor>.freeze, [">= 0.20.3", "< 2.0"])
    s.add_runtime_dependency(%q<tins>.freeze, ["~> 1.16"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 1.16", "< 3"])
    s.add_development_dependency(%q<simplecov-lcov>.freeze, ["~> 0.8.0"])
  else
    s.add_dependency(%q<simplecov>.freeze, [">= 0.18.1", "< 0.22.0"])
    s.add_dependency(%q<term-ansicolor>.freeze, ["~> 1.6"])
    s.add_dependency(%q<thor>.freeze, [">= 0.20.3", "< 2.0"])
    s.add_dependency(%q<tins>.freeze, ["~> 1.16"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.16", "< 3"])
    s.add_dependency(%q<simplecov-lcov>.freeze, ["~> 0.8.0"])
  end
end
