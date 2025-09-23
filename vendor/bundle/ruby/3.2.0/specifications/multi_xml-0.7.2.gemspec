# -*- encoding: utf-8 -*-
# stub: multi_xml 0.7.2 ruby lib

Gem::Specification.new do |s|
  s.name = "multi_xml".freeze
  s.version = "0.7.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "bug_tracker_uri" => "https://github.com/sferik/multi_xml/issues", "changelog_uri" => "https://github.com/sferik/multi_xml/blob/master/CHANGELOG.md", "documentation_uri" => "https://rubydoc.info/gems/multi_xml/", "funding_uri" => "https://github.com/sponsors/sferik", "homepage_uri" => "https://github.com/sferik/multi_xml", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/sferik/multi_xml" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Erik Berlin".freeze]
  s.bindir = "exe".freeze
  s.date = "1980-01-02"
  s.email = ["sferik@gmail.com".freeze]
  s.homepage = "https://github.com/sferik/multi_xml".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.2".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Provides swappable XML backends utilizing LibXML, Nokogiri, Ox, or REXML.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<bigdecimal>.freeze, ["~> 3.1"])
end
