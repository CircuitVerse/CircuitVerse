# -*- encoding: utf-8 -*-
# stub: activity_notification 2.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "activity_notification".freeze
  s.version = "2.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Shota Yamazaki".freeze]
  s.date = "2021-04-18"
  s.description = "Integrated user activity notifications for Ruby on Rails. Provides functions to configure multiple notification targets and make activity notifications with notifiable models, like adding comments, responding etc.".freeze
  s.email = ["shota.yamazaki.8@gmail.com".freeze]
  s.homepage = "https://github.com/simukappu/activity_notification".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1.0".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Integrated user activity notifications for Ruby on Rails".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, [">= 5.0.0", "< 6.2"])
      s.add_runtime_dependency(%q<i18n>.freeze, [">= 0.5.0"])
      s.add_runtime_dependency(%q<jquery-rails>.freeze, [">= 3.1.1"])
      s.add_runtime_dependency(%q<swagger-blocks>.freeze, [">= 3.0.0"])
      s.add_development_dependency(%q<puma>.freeze, [">= 3.12.0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 1.3.13"])
      s.add_development_dependency(%q<mysql2>.freeze, [">= 0.5.2"])
      s.add_development_dependency(%q<pg>.freeze, [">= 1.0.0"])
      s.add_development_dependency(%q<mongoid>.freeze, [">= 4.0.0"])
      s.add_development_dependency(%q<dynamoid>.freeze, ["= 3.1.0"])
      s.add_development_dependency(%q<rspec-rails>.freeze, [">= 3.8.0"])
      s.add_development_dependency(%q<factory_bot_rails>.freeze, [">= 4.11.0", "< 5.0.0"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0"])
      s.add_development_dependency(%q<yard>.freeze, [">= 0.9.16"])
      s.add_development_dependency(%q<yard-activesupport-concern>.freeze, [">= 0.0.1"])
      s.add_development_dependency(%q<devise>.freeze, [">= 4.5.0"])
      s.add_development_dependency(%q<devise_token_auth>.freeze, [">= 1.1.3"])
      s.add_development_dependency(%q<mongoid-locker>.freeze, [">= 2.0.0"])
      s.add_development_dependency(%q<aws-sdk-sns>.freeze, ["~> 1"])
      s.add_development_dependency(%q<slack-notifier>.freeze, [">= 1.5.1"])
    else
      s.add_dependency(%q<railties>.freeze, [">= 5.0.0", "< 6.2"])
      s.add_dependency(%q<i18n>.freeze, [">= 0.5.0"])
      s.add_dependency(%q<jquery-rails>.freeze, [">= 3.1.1"])
      s.add_dependency(%q<swagger-blocks>.freeze, [">= 3.0.0"])
      s.add_dependency(%q<puma>.freeze, [">= 3.12.0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 1.3.13"])
      s.add_dependency(%q<mysql2>.freeze, [">= 0.5.2"])
      s.add_dependency(%q<pg>.freeze, [">= 1.0.0"])
      s.add_dependency(%q<mongoid>.freeze, [">= 4.0.0"])
      s.add_dependency(%q<dynamoid>.freeze, ["= 3.1.0"])
      s.add_dependency(%q<rspec-rails>.freeze, [">= 3.8.0"])
      s.add_dependency(%q<factory_bot_rails>.freeze, [">= 4.11.0", "< 5.0.0"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0"])
      s.add_dependency(%q<yard>.freeze, [">= 0.9.16"])
      s.add_dependency(%q<yard-activesupport-concern>.freeze, [">= 0.0.1"])
      s.add_dependency(%q<devise>.freeze, [">= 4.5.0"])
      s.add_dependency(%q<devise_token_auth>.freeze, [">= 1.1.3"])
      s.add_dependency(%q<mongoid-locker>.freeze, [">= 2.0.0"])
      s.add_dependency(%q<aws-sdk-sns>.freeze, ["~> 1"])
      s.add_dependency(%q<slack-notifier>.freeze, [">= 1.5.1"])
    end
  else
    s.add_dependency(%q<railties>.freeze, [">= 5.0.0", "< 6.2"])
    s.add_dependency(%q<i18n>.freeze, [">= 0.5.0"])
    s.add_dependency(%q<jquery-rails>.freeze, [">= 3.1.1"])
    s.add_dependency(%q<swagger-blocks>.freeze, [">= 3.0.0"])
    s.add_dependency(%q<puma>.freeze, [">= 3.12.0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 1.3.13"])
    s.add_dependency(%q<mysql2>.freeze, [">= 0.5.2"])
    s.add_dependency(%q<pg>.freeze, [">= 1.0.0"])
    s.add_dependency(%q<mongoid>.freeze, [">= 4.0.0"])
    s.add_dependency(%q<dynamoid>.freeze, ["= 3.1.0"])
    s.add_dependency(%q<rspec-rails>.freeze, [">= 3.8.0"])
    s.add_dependency(%q<factory_bot_rails>.freeze, [">= 4.11.0", "< 5.0.0"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0"])
    s.add_dependency(%q<yard>.freeze, [">= 0.9.16"])
    s.add_dependency(%q<yard-activesupport-concern>.freeze, [">= 0.0.1"])
    s.add_dependency(%q<devise>.freeze, [">= 4.5.0"])
    s.add_dependency(%q<devise_token_auth>.freeze, [">= 1.1.3"])
    s.add_dependency(%q<mongoid-locker>.freeze, [">= 2.0.0"])
    s.add_dependency(%q<aws-sdk-sns>.freeze, ["~> 1"])
    s.add_dependency(%q<slack-notifier>.freeze, [">= 1.5.1"])
  end
end
