# -*- encoding: utf-8 -*-
# stub: hairtrigger 1.3.1 ruby lib

Gem::Specification.new do |s|
  s.name = "hairtrigger".freeze
  s.version = "1.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jon Jensen".freeze]
  s.date = "2025-03-31"
  s.description = "allows you to declare database triggers in ruby in your models, and then generate appropriate migrations as they change".freeze
  s.email = "jenseng@gmail.com".freeze
  s.homepage = "http://github.com/jenseng/hair_trigger".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "easy database triggers for active record".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 6.0", "< 9"])
  s.add_runtime_dependency(%q<ruby_parser>.freeze, ["~> 3.10"])
  s.add_runtime_dependency(%q<ruby2ruby>.freeze, ["~> 2.4"])
end
