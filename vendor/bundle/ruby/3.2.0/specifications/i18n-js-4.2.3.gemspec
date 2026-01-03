# -*- encoding: utf-8 -*-
# stub: i18n-js 4.2.3 ruby lib

Gem::Specification.new do |s|
  s.name = "i18n-js".freeze
  s.version = "4.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/fnando/i18n-js/issues", "changelog_uri" => "https://github.com/fnando/i18n-js/tree/v4.2.3/CHANGELOG.md", "documentation_uri" => "https://github.com/fnando/i18n-js/tree/v4.2.3/README.md", "homepage_uri" => "https://github.com/fnando/i18n-js", "license_uri" => "https://github.com/fnando/i18n-js/tree/v4.2.3/LICENSE.md", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/fnando/i18n-js/tree/v4.2.3" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nando Vieira".freeze]
  s.bindir = "exe".freeze
  s.date = "2023-03-29"
  s.description = "Export i18n translations and use them on JavaScript.".freeze
  s.email = ["me@fnando.com".freeze]
  s.executables = ["i18n".freeze]
  s.files = ["exe/i18n".freeze]
  s.homepage = "https://github.com/fnando/i18n-js".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "Export i18n translations and use them on JavaScript.".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<glob>.freeze, [">= 0.4.0"])
  s.add_runtime_dependency(%q<i18n>.freeze, [">= 0"])
  s.add_development_dependency(%q<activesupport>.freeze, [">= 0"])
  s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
  s.add_development_dependency(%q<minitest-utils>.freeze, [">= 0"])
  s.add_development_dependency(%q<mocha>.freeze, [">= 0"])
  s.add_development_dependency(%q<pry-meta>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop-fnando>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
end
