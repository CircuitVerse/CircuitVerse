# -*- encoding: utf-8 -*-
# stub: factory_bot_rails 6.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "factory_bot_rails".freeze
  s.version = "6.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Joe Ferris".freeze]
  s.date = "2021-05-07"
  s.description = "factory_bot_rails provides integration between factory_bot and rails 5.0 or newer".freeze
  s.email = "jferris@thoughtbot.com".freeze
  s.homepage = "https://github.com/thoughtbot/factory_bot_rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.7".freeze
  s.summary = "factory_bot_rails provides integration between factory_bot and rails 5.0 or newer".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<factory_bot>.freeze, ["~> 6.2.0"])
    s.add_runtime_dependency(%q<railties>.freeze, [">= 5.0.0"])
  else
    s.add_dependency(%q<factory_bot>.freeze, ["~> 6.2.0"])
    s.add_dependency(%q<railties>.freeze, [">= 5.0.0"])
  end
end
