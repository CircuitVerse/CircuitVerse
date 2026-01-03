# -*- encoding: utf-8 -*-
# stub: sentry-ruby 5.26.0 ruby lib

Gem::Specification.new do |s|
  s.name = "sentry-ruby".freeze
  s.version = "5.26.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/getsentry/sentry-ruby/issues", "changelog_uri" => "https://github.com/getsentry/sentry-ruby/blob/5.26.0/CHANGELOG.md", "documentation_uri" => "http://www.rubydoc.info/gems/sentry-ruby/5.26.0", "homepage_uri" => "https://github.com/getsentry/sentry-ruby/tree/5.26.0/sentry-ruby", "source_code_uri" => "https://github.com/getsentry/sentry-ruby/tree/5.26.0/sentry-ruby" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Sentry Team".freeze]
  s.date = "1980-01-02"
  s.description = "A gem that provides a client interface for the Sentry error logger".freeze
  s.email = "accounts@sentry.io".freeze
  s.extra_rdoc_files = ["LICENSE.txt".freeze, "README.md".freeze]
  s.files = ["LICENSE.txt".freeze, "README.md".freeze]
  s.homepage = "https://github.com/getsentry/sentry-ruby/tree/5.26.0/sentry-ruby".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "A gem that provides a client interface for the Sentry error logger".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0", ">= 1.0.2"])
  s.add_runtime_dependency(%q<bigdecimal>.freeze, [">= 0"])
end
