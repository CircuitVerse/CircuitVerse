# -*- encoding: utf-8 -*-
# stub: flipper-ui 0.28.0 ruby lib

Gem::Specification.new do |s|
  s.name = "flipper-ui".freeze
  s.version = "0.28.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/jnunemaker/flipper/blob/main/Changelog.md" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["John Nunemaker".freeze]
  s.date = "2023-03-21"
  s.email = ["nunemaker@gmail.com".freeze]
  s.homepage = "https://github.com/jnunemaker/flipper".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.32".freeze
  s.summary = "UI for the Flipper gem".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rack>.freeze, [">= 1.4", "< 3"])
    s.add_runtime_dependency(%q<rack-protection>.freeze, [">= 1.5.3", "<= 4.0.0"])
    s.add_runtime_dependency(%q<flipper>.freeze, ["~> 0.28.0"])
    s.add_runtime_dependency(%q<erubi>.freeze, [">= 1.0.0", "< 2.0.0"])
    s.add_runtime_dependency(%q<sanitize>.freeze, ["< 7"])
  else
    s.add_dependency(%q<rack>.freeze, [">= 1.4", "< 3"])
    s.add_dependency(%q<rack-protection>.freeze, [">= 1.5.3", "<= 4.0.0"])
    s.add_dependency(%q<flipper>.freeze, ["~> 0.28.0"])
    s.add_dependency(%q<erubi>.freeze, [">= 1.0.0", "< 2.0.0"])
    s.add_dependency(%q<sanitize>.freeze, ["< 7"])
  end
end
