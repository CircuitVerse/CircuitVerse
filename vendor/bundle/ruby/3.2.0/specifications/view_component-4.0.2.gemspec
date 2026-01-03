# -*- encoding: utf-8 -*-
# stub: view_component 4.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "view_component".freeze
  s.version = "4.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "changelog_uri" => "https://github.com/ViewComponent/view_component/blob/main/docs/CHANGELOG.md", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/viewcomponent/view_component" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["ViewComponent Team".freeze]
  s.date = "1980-01-02"
  s.homepage = "https://viewcomponent.org".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.2.0".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "A framework for building reusable, testable & encapsulated view components in Ruby on Rails.".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 7.1.0", "< 8.1"])
  s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1"])
end
