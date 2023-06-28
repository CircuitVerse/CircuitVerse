# -*- encoding: utf-8 -*-
# stub: hairtrigger 0.2.25 ruby lib

Gem::Specification.new do |s|
  s.name = "hairtrigger".freeze
  s.version = "0.2.25"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jon Jensen".freeze]
  s.date = "2022-01-26"
  s.description = "allows you to declare database triggers in ruby in your models, and then generate appropriate migrations as they change".freeze
  s.email = "jenseng@gmail.com".freeze
  s.homepage = "http://github.com/jenseng/hair_trigger".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.2.32".freeze
  s.summary = "easy database triggers for active record".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activerecord>.freeze, [">= 5.0", "< 8"])
    s.add_runtime_dependency(%q<ruby_parser>.freeze, ["~> 3.10"])
    s.add_runtime_dependency(%q<ruby2ruby>.freeze, ["~> 2.4"])
  else
    s.add_dependency(%q<activerecord>.freeze, [">= 5.0", "< 8"])
    s.add_dependency(%q<ruby_parser>.freeze, ["~> 3.10"])
    s.add_dependency(%q<ruby2ruby>.freeze, ["~> 2.4"])
  end
end
