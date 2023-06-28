# -*- encoding: utf-8 -*-
# stub: ims-lti 1.2.4 ruby lib

Gem::Specification.new do |s|
  s.name = "ims-lti".freeze
  s.version = "1.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Instructure".freeze]
  s.date = "2020-02-07"
  s.extra_rdoc_files = ["LICENSE".freeze]
  s.files = ["LICENSE".freeze]
  s.homepage = "http://github.com/instructure/ims-lti".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Ruby library for creating IMS LTI tool providers and consumers".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<builder>.freeze, [">= 1.0", "< 4.0"])
    s.add_runtime_dependency(%q<oauth>.freeze, [">= 0.4.5", "< 0.6"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0", "> 3.0"])
  else
    s.add_dependency(%q<builder>.freeze, [">= 1.0", "< 4.0"])
    s.add_dependency(%q<oauth>.freeze, [">= 0.4.5", "< 0.6"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0", "> 3.0"])
  end
end
