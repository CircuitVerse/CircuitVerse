# -*- encoding: utf-8 -*-
# stub: rails 7.0.3.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rails".freeze
  s.version = "7.0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.8.11".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/rails/rails/issues", "changelog_uri" => "https://github.com/rails/rails/releases/tag/v7.0.3.1", "documentation_uri" => "https://api.rubyonrails.org/v7.0.3.1/", "mailing_list_uri" => "https://discuss.rubyonrails.org/c/rubyonrails-talk", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/rails/rails/tree/v7.0.3.1" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2022-07-12"
  s.description = "Ruby on Rails is a full-stack web framework optimized for programmer happiness and sustainable productivity. It encourages beautiful code by favoring convention over configuration.".freeze
  s.email = "david@loudthinking.com".freeze
  s.homepage = "https://rubyonrails.org".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Full-stack web application framework.".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, ["= 7.0.3.1"])
    s.add_runtime_dependency(%q<actionpack>.freeze, ["= 7.0.3.1"])
    s.add_runtime_dependency(%q<actionview>.freeze, ["= 7.0.3.1"])
    s.add_runtime_dependency(%q<activemodel>.freeze, ["= 7.0.3.1"])
    s.add_runtime_dependency(%q<activerecord>.freeze, ["= 7.0.3.1"])
    s.add_runtime_dependency(%q<actionmailer>.freeze, ["= 7.0.3.1"])
    s.add_runtime_dependency(%q<activejob>.freeze, ["= 7.0.3.1"])
    s.add_runtime_dependency(%q<actioncable>.freeze, ["= 7.0.3.1"])
    s.add_runtime_dependency(%q<activestorage>.freeze, ["= 7.0.3.1"])
    s.add_runtime_dependency(%q<actionmailbox>.freeze, ["= 7.0.3.1"])
    s.add_runtime_dependency(%q<actiontext>.freeze, ["= 7.0.3.1"])
    s.add_runtime_dependency(%q<railties>.freeze, ["= 7.0.3.1"])
    s.add_runtime_dependency(%q<bundler>.freeze, [">= 1.15.0"])
  else
    s.add_dependency(%q<activesupport>.freeze, ["= 7.0.3.1"])
    s.add_dependency(%q<actionpack>.freeze, ["= 7.0.3.1"])
    s.add_dependency(%q<actionview>.freeze, ["= 7.0.3.1"])
    s.add_dependency(%q<activemodel>.freeze, ["= 7.0.3.1"])
    s.add_dependency(%q<activerecord>.freeze, ["= 7.0.3.1"])
    s.add_dependency(%q<actionmailer>.freeze, ["= 7.0.3.1"])
    s.add_dependency(%q<activejob>.freeze, ["= 7.0.3.1"])
    s.add_dependency(%q<actioncable>.freeze, ["= 7.0.3.1"])
    s.add_dependency(%q<activestorage>.freeze, ["= 7.0.3.1"])
    s.add_dependency(%q<actionmailbox>.freeze, ["= 7.0.3.1"])
    s.add_dependency(%q<actiontext>.freeze, ["= 7.0.3.1"])
    s.add_dependency(%q<railties>.freeze, ["= 7.0.3.1"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.15.0"])
  end
end
