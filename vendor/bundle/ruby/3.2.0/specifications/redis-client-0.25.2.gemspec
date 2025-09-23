# -*- encoding: utf-8 -*-
# stub: redis-client 0.25.2 ruby lib

Gem::Specification.new do |s|
  s.name = "redis-client".freeze
  s.version = "0.25.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "changelog_uri" => "https://github.com/redis-rb/redis-client/blob/master/CHANGELOG.md", "homepage_uri" => "https://github.com/redis-rb/redis-client", "source_code_uri" => "https://github.com/redis-rb/redis-client" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jean Boussier".freeze]
  s.date = "2025-08-10"
  s.email = ["jean.boussier@gmail.com".freeze]
  s.homepage = "https://github.com/redis-rb/redis-client".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Simple low-level client for Redis 6+".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<connection_pool>.freeze, [">= 0"])
end
