# -*- encoding: utf-8 -*-
# stub: actiontext 6.0.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "actiontext".freeze
  s.version = "6.0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/rails/rails/issues", "changelog_uri" => "https://github.com/rails/rails/blob/v6.0.2.1/actiontext/CHANGELOG.md", "documentation_uri" => "https://api.rubyonrails.org/v6.0.2.1/", "mailing_list_uri" => "https://groups.google.com/forum/#!forum/rubyonrails-talk", "source_code_uri" => "https://github.com/rails/rails/tree/v6.0.2.1/actiontext" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Javan Makhmali".freeze, "Sam Stephenson".freeze, "David Heinemeier Hansson".freeze]
  s.date = "2019-12-18"
  s.description = "Edit and display rich text in Rails applications.".freeze
  s.email = ["javan@javan.us".freeze, "sstephenson@gmail.com".freeze, "david@loudthinking.com".freeze]
  s.homepage = "https://rubyonrails.org".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Rich text framework.".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, ["= 6.0.2.1"])
      s.add_runtime_dependency(%q<activerecord>.freeze, ["= 6.0.2.1"])
      s.add_runtime_dependency(%q<activestorage>.freeze, ["= 6.0.2.1"])
      s.add_runtime_dependency(%q<actionpack>.freeze, ["= 6.0.2.1"])
      s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 1.8.5"])
    else
      s.add_dependency(%q<activesupport>.freeze, ["= 6.0.2.1"])
      s.add_dependency(%q<activerecord>.freeze, ["= 6.0.2.1"])
      s.add_dependency(%q<activestorage>.freeze, ["= 6.0.2.1"])
      s.add_dependency(%q<actionpack>.freeze, ["= 6.0.2.1"])
      s.add_dependency(%q<nokogiri>.freeze, [">= 1.8.5"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, ["= 6.0.2.1"])
    s.add_dependency(%q<activerecord>.freeze, ["= 6.0.2.1"])
    s.add_dependency(%q<activestorage>.freeze, ["= 6.0.2.1"])
    s.add_dependency(%q<actionpack>.freeze, ["= 6.0.2.1"])
    s.add_dependency(%q<nokogiri>.freeze, [">= 1.8.5"])
  end
end
