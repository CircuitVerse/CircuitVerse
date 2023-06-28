# -*- encoding: utf-8 -*-
# stub: i18n_data 0.16.0 ruby lib

Gem::Specification.new do |s|
  s.name = "i18n_data".freeze
  s.version = "0.16.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Grosser".freeze]
  s.date = "2022-02-10"
  s.email = "michael@grosser.it".freeze
  s.homepage = "https://github.com/grosser/i18n_data".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "country/language names and 2-letter-code pairs, in 85 languages".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<simple_po_parser>.freeze, ["~> 1.1"])
  else
    s.add_dependency(%q<simple_po_parser>.freeze, ["~> 1.1"])
  end
end
