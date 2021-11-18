# -*- encoding: utf-8 -*-
# stub: jbuilder 2.11.2 ruby lib

Gem::Specification.new do |s|
  s.name = "jbuilder".freeze
  s.version = "2.11.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2021-01-27"
  s.email = "david@basecamp.com".freeze
  s.homepage = "https://github.com/rails/jbuilder".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.2".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Create JSON structures via a Builder-style DSL".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.0.0"])
    else
      s.add_dependency(%q<activesupport>.freeze, [">= 5.0.0"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 5.0.0"])
  end
end
