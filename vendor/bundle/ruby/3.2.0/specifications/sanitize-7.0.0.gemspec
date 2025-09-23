# -*- encoding: utf-8 -*-
# stub: sanitize 7.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "sanitize".freeze
  s.version = "7.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/rgrove/sanitize/blob/main/CHANGELOG.md", "documentation_uri" => "https://rubydoc.info/github/rgrove/sanitize", "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ryan Grove".freeze]
  s.date = "2024-12-30"
  s.description = "Sanitize is an allowlist-based HTML and CSS sanitizer. It removes all HTML\nand/or CSS from a string except the elements, attributes, and properties you\nchoose to allow.'\n".freeze
  s.email = "ryan@wonko.com".freeze
  s.homepage = "https://github.com/rgrove/sanitize/".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Allowlist-based HTML and CSS sanitizer.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<crass>.freeze, ["~> 1.0.2"])
  s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 1.16.8"])
end
