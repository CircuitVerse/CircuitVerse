# -*- encoding: utf-8 -*-
# stub: globalid 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "globalid".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2021-11-25"
  s.description = "URIs for your models makes it easy to pass references around.".freeze
  s.email = "david@loudthinking.com".freeze
  s.homepage = "http://www.rubyonrails.org".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.3.5".freeze
  s.summary = "Refer to any model with a URI: gid://app/class/id".freeze

  s.installed_by_version = "3.3.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 5.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
