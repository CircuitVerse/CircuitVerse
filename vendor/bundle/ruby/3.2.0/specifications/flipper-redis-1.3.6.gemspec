# -*- encoding: utf-8 -*-
# stub: flipper-redis 1.3.6 ruby lib

Gem::Specification.new do |s|
  s.name = "flipper-redis".freeze
  s.version = "1.3.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/flippercloud/flipper/issues", "changelog_uri" => "https://github.com/flippercloud/flipper/releases/tag/v1.3.6", "documentation_uri" => "https://www.flippercloud.io/docs", "funding_uri" => "https://github.com/sponsors/flippercloud", "homepage_uri" => "https://www.flippercloud.io", "source_code_uri" => "https://github.com/flippercloud/flipper" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["John Nunemaker".freeze]
  s.date = "1980-01-02"
  s.email = "support@flippercloud.io".freeze
  s.homepage = "https://www.flippercloud.io/docs/adapters/redis".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.6".freeze
  s.summary = "Redis feature flag adapter for Flipper".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<flipper>.freeze, ["~> 1.3.6"])
  s.add_runtime_dependency(%q<redis>.freeze, [">= 3.0", "< 6"])
end
