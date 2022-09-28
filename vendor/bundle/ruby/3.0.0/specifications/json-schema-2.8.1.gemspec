# -*- encoding: utf-8 -*-
# stub: json-schema 2.8.1 ruby lib

Gem::Specification.new do |s|
  s.name = "json-schema".freeze
  s.version = "2.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.8".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Kenny Hoxworth".freeze]
  s.date = "2018-10-14"
  s.email = "hoxworth@gmail.com".freeze
  s.extra_rdoc_files = ["README.md".freeze, "LICENSE.md".freeze]
  s.files = ["LICENSE.md".freeze, "README.md".freeze]
  s.homepage = "http://github.com/ruby-json-schema/json-schema/tree/master".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9".freeze)
  s.rubygems_version = "3.2.32".freeze
  s.summary = "Ruby JSON Schema Validator".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_development_dependency(%q<webmock>.freeze, [">= 0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<addressable>.freeze, [">= 2.4"])
  else
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_dependency(%q<webmock>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<addressable>.freeze, [">= 2.4"])
  end
end
