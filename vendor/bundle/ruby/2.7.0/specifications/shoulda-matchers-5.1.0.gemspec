# -*- encoding: utf-8 -*-
# stub: shoulda-matchers 5.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "shoulda-matchers".freeze
  s.version = "5.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/thoughtbot/shoulda-matchers/issues", "changelog_uri" => "https://github.com/thoughtbot/shoulda-matchers/blob/master/CHANGELOG.md", "documentation_uri" => "https://matchers.shoulda.io/docs", "homepage_uri" => "https://matchers.shoulda.io", "source_code_uri" => "https://github.com/thoughtbot/shoulda-matchers" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tammer Saleh".freeze, "Joe Ferris".freeze, "Ryan McGeary".freeze, "Dan Croak".freeze, "Matt Jankowski".freeze, "Stafford Brunk".freeze, "Elliot Winkler".freeze]
  s.date = "2021-12-22"
  s.description = "Shoulda Matchers provides RSpec- and Minitest-compatible one-liners to test common Rails functionality that, if written by hand, would be much longer, more complex, and error-prone. ".freeze
  s.email = "support@thoughtbot.com".freeze
  s.homepage = "https://matchers.shoulda.io/".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Simple one-liner tests for common Rails functionality".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.2.0"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 5.2.0"])
  end
end
