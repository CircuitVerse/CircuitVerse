# -*- encoding: utf-8 -*-
# stub: web-console 4.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "web-console".freeze
  s.version = "4.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Hailey Somerville".freeze, "Genadi Samokovarov".freeze, "Guillermo Iguaran".freeze, "Ryan Dao".freeze]
  s.date = "2021-11-17"
  s.email = ["hailey@hailey.lol".freeze, "gsamokovarov@gmail.com".freeze, "guilleiguaran@gmail.com".freeze, "daoduyducduong@gmail.com".freeze]
  s.homepage = "https://github.com/rails/web-console".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "A debugging tool for your Ruby on Rails applications.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<railties>.freeze, [">= 6.0.0"])
    s.add_runtime_dependency(%q<activemodel>.freeze, [">= 6.0.0"])
    s.add_runtime_dependency(%q<actionview>.freeze, [">= 6.0.0"])
    s.add_runtime_dependency(%q<bindex>.freeze, [">= 0.4.0"])
  else
    s.add_dependency(%q<railties>.freeze, [">= 6.0.0"])
    s.add_dependency(%q<activemodel>.freeze, [">= 6.0.0"])
    s.add_dependency(%q<actionview>.freeze, [">= 6.0.0"])
    s.add_dependency(%q<bindex>.freeze, [">= 0.4.0"])
  end
end
