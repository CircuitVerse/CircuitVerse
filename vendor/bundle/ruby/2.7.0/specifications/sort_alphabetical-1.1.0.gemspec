# -*- encoding: utf-8 -*-
# stub: sort_alphabetical 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "sort_alphabetical".freeze
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Grosser".freeze]
  s.date = "2016-11-23"
  s.email = "michael@grosser.it".freeze
  s.homepage = "https://github.com/grosser/sort_alphabetical".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Sort UTF8 Strings alphabetical via Enumerable extension".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<unicode_utils>.freeze, [">= 1.2.2"])
  else
    s.add_dependency(%q<unicode_utils>.freeze, [">= 1.2.2"])
  end
end
