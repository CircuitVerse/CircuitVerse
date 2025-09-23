# -*- encoding: utf-8 -*-
# stub: pg_search 2.3.7 ruby lib

Gem::Specification.new do |s|
  s.name = "pg_search".freeze
  s.version = "2.3.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Grant Hutchins".freeze, "Case Commons, LLC".freeze]
  s.date = "2024-08-11"
  s.description = "PgSearch builds Active Record named scopes that take advantage of PostgreSQL's full text search".freeze
  s.email = ["gems@nertzy.com".freeze, "casecommons-dev@googlegroups.com".freeze]
  s.homepage = "https://github.com/Casecommons/pg_search".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "PgSearch builds Active Record named scopes that take advantage of PostgreSQL's full text search".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 6.1"])
  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 6.1"])
end
