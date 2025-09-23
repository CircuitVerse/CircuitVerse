# -*- encoding: utf-8 -*-
# stub: job-iteration 1.11.0 ruby lib

Gem::Specification.new do |s|
  s.name = "job-iteration".freeze
  s.version = "1.11.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "changelog_uri" => "https://github.com/Shopify/job-iteration/blob/main/CHANGELOG.md" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Shopify".freeze]
  s.bindir = "exe".freeze
  s.date = "1980-01-02"
  s.description = "Makes your background jobs interruptible and resumable.".freeze
  s.email = ["ops-accounts+shipit@shopify.com".freeze]
  s.homepage = "https://github.com/shopify/job-iteration".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Makes your background jobs interruptible and resumable.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activejob>.freeze, [">= 6.1"])
end
