# -*- encoding: utf-8 -*-
# stub: flipper-ui 1.3.6 ruby lib

Gem::Specification.new do |s|
  s.name = "flipper-ui".freeze
  s.version = "1.3.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/flippercloud/flipper/issues", "changelog_uri" => "https://github.com/flippercloud/flipper/releases/tag/v1.3.6", "documentation_uri" => "https://www.flippercloud.io/docs", "funding_uri" => "https://github.com/sponsors/flippercloud", "homepage_uri" => "https://www.flippercloud.io", "source_code_uri" => "https://github.com/flippercloud/flipper" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["John Nunemaker".freeze]
  s.date = "1980-01-02"
  s.email = "support@flippercloud.io".freeze
  s.homepage = "https://www.flippercloud.io/docs/ui".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Feature flag UI for the Flipper gem".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rack>.freeze, [">= 1.4", "< 4"])
  s.add_runtime_dependency(%q<rack-protection>.freeze, [">= 1.5.3", "< 5.0.0"])
  s.add_runtime_dependency(%q<rack-session>.freeze, [">= 1.0.2", "< 3.0.0"])
  s.add_runtime_dependency(%q<flipper>.freeze, ["~> 1.3.6"])
  s.add_runtime_dependency(%q<erubi>.freeze, [">= 1.0.0", "< 2.0.0"])
  s.add_runtime_dependency(%q<sanitize>.freeze, ["< 8"])
end
