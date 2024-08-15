# -*- encoding: utf-8 -*-
# stub: language_filter 0.3.01 ruby lib

Gem::Specification.new do |s|
  s.name = "language_filter".freeze
  s.version = "0.3.01"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Chris Fritz".freeze]
  s.date = "2013-07-09"
  s.description = "LanguageFilter is a Ruby gem to detect and optionally filter various categories of language.".freeze
  s.email = ["chrisvfritz@gmail.com".freeze]
  s.homepage = "http://github.com/chrisvfritz/language_filter".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.7".freeze
  s.summary = "LanguageFilter is a Ruby gem to detect and optionally filter various categories of language.".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
