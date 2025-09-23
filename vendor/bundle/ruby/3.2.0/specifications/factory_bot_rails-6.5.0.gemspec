# -*- encoding: utf-8 -*-
# stub: factory_bot_rails 6.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "factory_bot_rails".freeze
  s.version = "6.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/thoughtbot/factory_bot_rails/blob/main/NEWS.md" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Joe Ferris".freeze]
  s.date = "2025-06-13"
  s.description = "factory_bot_rails provides integration between factory_bot and Rails 6.1 or newer".freeze
  s.email = "jferris@thoughtbot.com".freeze
  s.homepage = "https://github.com/thoughtbot/factory_bot_rails".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "factory_bot_rails provides integration between factory_bot and Rails 6.1 or newer".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<factory_bot>.freeze, ["~> 6.5"])
  s.add_runtime_dependency(%q<railties>.freeze, [">= 6.1.0"])
  s.add_development_dependency(%q<activerecord>.freeze, [">= 6.1.0"])
  s.add_development_dependency(%q<activestorage>.freeze, [">= 6.1.0"])
  s.add_development_dependency(%q<mutex_m>.freeze, [">= 0"])
  s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
end
