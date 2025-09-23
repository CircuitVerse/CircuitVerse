# -*- encoding: utf-8 -*-
# stub: activemodel-serializers-xml 1.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "activemodel-serializers-xml".freeze
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Rails team".freeze]
  s.date = "2024-09-18"
  s.email = ["security@rubyonrails.com".freeze]
  s.homepage = "http://github.com/rails/activemodel-serializers-xml".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "XML serialization for your Active Model objects and Active Record models - extracted from Rails".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.0.0.a"])
  s.add_runtime_dependency(%q<activemodel>.freeze, [">= 5.0.0.a"])
  s.add_runtime_dependency(%q<builder>.freeze, ["~> 3.1"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<activerecord>.freeze, [">= 0"])
  s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
  s.add_development_dependency(%q<rexml>.freeze, [">= 0"])
end
