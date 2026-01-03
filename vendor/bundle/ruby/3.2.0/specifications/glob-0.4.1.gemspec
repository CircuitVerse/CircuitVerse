# -*- encoding: utf-8 -*-
# stub: glob 0.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "glob".freeze
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/fnando/glob/issues", "changelog_uri" => "https://github.com/fnando/glob/tree/v0.4.1/CHANGELOG.md", "documentation_uri" => "https://github.com/fnando/glob/tree/v0.4.1/README.md", "homepage_uri" => "https://github.com/fnando/glob", "license_uri" => "https://github.com/fnando/glob/tree/v0.4.1/LICENSE.md", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/fnando/glob/tree/v0.4.1" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nando Vieira".freeze]
  s.bindir = "exe".freeze
  s.date = "2024-01-03"
  s.description = "Create a list of hash paths that match a given pattern. You can also generate a hash with only the matching paths.".freeze
  s.email = ["me@fnando.com".freeze]
  s.homepage = "https://github.com/fnando/glob".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "Create a list of hash paths that match a given pattern. You can also generate a hash with only the matching paths.".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
  s.add_development_dependency(%q<minitest-utils>.freeze, [">= 0"])
  s.add_development_dependency(%q<pry-meta>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop-fnando>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
end
