# -*- encoding: utf-8 -*-
# stub: ims-lti 1.1.13 ruby lib

Gem::Specification.new do |s|
  s.name = "ims-lti".freeze
  s.version = "1.1.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Instructure".freeze]
  s.date = "2015-01-09"
  s.extra_rdoc_files = ["LICENSE".freeze]
  s.files = ["LICENSE".freeze]
  s.homepage = "http://github.com/instructure/ims-lti".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Ruby library for creating IMS LTI tool providers and consumers".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<oauth>.freeze, [">= 0.4.5", "< 0.6"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
    else
      s.add_dependency(%q<builder>.freeze, [">= 0"])
      s.add_dependency(%q<oauth>.freeze, [">= 0.4.5", "< 0.6"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<builder>.freeze, [">= 0"])
    s.add_dependency(%q<oauth>.freeze, [">= 0.4.5", "< 0.6"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
  end
end
