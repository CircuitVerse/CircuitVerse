# -*- encoding: utf-8 -*-
# stub: railties 8.0.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "railties".freeze
  s.version = "8.0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/rails/rails/issues", "changelog_uri" => "https://github.com/rails/rails/blob/v8.0.2.1/railties/CHANGELOG.md", "documentation_uri" => "https://api.rubyonrails.org/v8.0.2.1/", "mailing_list_uri" => "https://discuss.rubyonrails.org/c/rubyonrails-talk", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/rails/rails/tree/v8.0.2.1/railties" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.bindir = "exe".freeze
  s.date = "1980-01-02"
  s.description = "Rails internals: application bootup, plugins, generators, and rake tasks.".freeze
  s.email = "david@loudthinking.com".freeze
  s.executables = ["rails".freeze]
  s.files = ["exe/rails".freeze]
  s.homepage = "https://rubyonrails.org".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--exclude".freeze, ".".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.2.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Tools for creating, working with, and running Rails applications.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activesupport>.freeze, ["= 8.0.2.1"])
  s.add_runtime_dependency(%q<actionpack>.freeze, ["= 8.0.2.1"])
  s.add_runtime_dependency(%q<rackup>.freeze, [">= 1.0.0"])
  s.add_runtime_dependency(%q<rake>.freeze, [">= 12.2"])
  s.add_runtime_dependency(%q<thor>.freeze, ["~> 1.0", ">= 1.2.2"])
  s.add_runtime_dependency(%q<zeitwerk>.freeze, ["~> 2.6"])
  s.add_runtime_dependency(%q<irb>.freeze, ["~> 1.13"])
  s.add_development_dependency(%q<actionview>.freeze, ["= 8.0.2.1"])
end
