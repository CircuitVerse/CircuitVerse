# -*- encoding: utf-8 -*-
# stub: actionmailbox 8.0.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "actionmailbox".freeze
  s.version = "8.0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/rails/rails/issues", "changelog_uri" => "https://github.com/rails/rails/blob/v8.0.2.1/actionmailbox/CHANGELOG.md", "documentation_uri" => "https://api.rubyonrails.org/v8.0.2.1/", "mailing_list_uri" => "https://discuss.rubyonrails.org/c/rubyonrails-talk", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/rails/rails/tree/v8.0.2.1/actionmailbox" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze, "George Claghorn".freeze]
  s.date = "1980-01-02"
  s.description = "Receive and process incoming emails in Rails applications.".freeze
  s.email = ["david@loudthinking.com".freeze, "george@basecamp.com".freeze]
  s.homepage = "https://rubyonrails.org".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.2.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Inbound email handling framework.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activesupport>.freeze, ["= 8.0.2.1"])
  s.add_runtime_dependency(%q<activerecord>.freeze, ["= 8.0.2.1"])
  s.add_runtime_dependency(%q<activestorage>.freeze, ["= 8.0.2.1"])
  s.add_runtime_dependency(%q<activejob>.freeze, ["= 8.0.2.1"])
  s.add_runtime_dependency(%q<actionpack>.freeze, ["= 8.0.2.1"])
  s.add_runtime_dependency(%q<mail>.freeze, [">= 2.8.0"])
end
