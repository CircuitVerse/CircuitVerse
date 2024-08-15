# -*- encoding: utf-8 -*-
# stub: simplecov 0.21.2 ruby lib

Gem::Specification.new do |s|
  s.name = "simplecov".freeze
  s.version = "0.21.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/simplecov-ruby/simplecov/issues", "changelog_uri" => "https://github.com/simplecov-ruby/simplecov/blob/main/CHANGELOG.md", "documentation_uri" => "https://www.rubydoc.info/gems/simplecov/0.21.2", "mailing_list_uri" => "https://groups.google.com/forum/#!forum/simplecov", "source_code_uri" => "https://github.com/simplecov-ruby/simplecov/tree/v0.21.2" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Christoph Olszowka".freeze, "Tobias Pfeiffer".freeze]
  s.date = "2021-01-09"
  s.description = "Code coverage for Ruby with a powerful configuration library and automatic merging of coverage across test suites".freeze
  s.email = ["christoph at olszowka de".freeze, "pragtob@gmail.com".freeze]
  s.homepage = "https://github.com/simplecov-ruby/simplecov".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Code coverage for Ruby".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<docile>.freeze, ["~> 1.1"])
    s.add_runtime_dependency(%q<simplecov-html>.freeze, ["~> 0.11"])
    s.add_runtime_dependency(%q<simplecov_json_formatter>.freeze, ["~> 0.1"])
  else
    s.add_dependency(%q<docile>.freeze, ["~> 1.1"])
    s.add_dependency(%q<simplecov-html>.freeze, ["~> 0.11"])
    s.add_dependency(%q<simplecov_json_formatter>.freeze, ["~> 0.1"])
  end
end
