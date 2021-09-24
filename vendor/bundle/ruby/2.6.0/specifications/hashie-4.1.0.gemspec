# -*- encoding: utf-8 -*-
# stub: hashie 4.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "hashie".freeze
  s.version = "4.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/hashie/hashie/issues", "changelog_uri" => "https://github.com/hashie/hashie/blob/master/CHANGELOG.md", "documentation_uri" => "https://www.rubydoc.info/gems/hashie", "source_code_uri" => "https://github.com/hashie/hashie" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Bleigh".freeze, "Jerry Cheung".freeze]
  s.date = "2020-02-01"
  s.description = "Hashie is a collection of classes and mixins that make hashes more powerful.".freeze
  s.email = ["michael@intridea.com".freeze, "jollyjerry@gmail.com".freeze]
  s.homepage = "https://github.com/hashie/hashie".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Your friendly neighborhood hash library.".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    else
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
  end
end
