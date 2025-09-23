# -*- encoding: utf-8 -*-
# stub: noticed 1.6.3 ruby lib

Gem::Specification.new do |s|
  s.name = "noticed".freeze
  s.version = "1.6.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Chris Oliver".freeze]
  s.date = "2023-05-11"
  s.description = "Database, browser, realtime ActionCable, Email, SMS, Slack notifications, and more for Rails apps".freeze
  s.email = ["excid3@gmail.com".freeze]
  s.homepage = "https://github.com/excid3/noticed".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Notifications for Ruby on Rails applications".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rails>.freeze, [">= 5.2.0"])
  s.add_runtime_dependency(%q<http>.freeze, [">= 4.0.0"])
end
