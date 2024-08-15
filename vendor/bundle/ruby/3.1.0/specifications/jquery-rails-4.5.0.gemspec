# -*- encoding: utf-8 -*-
# stub: jquery-rails 4.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "jquery-rails".freeze
  s.version = "4.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andr\u00E9 Arko".freeze]
  s.date = "2022-05-23"
  s.description = "This gem provides jQuery and the jQuery-ujs driver for your Rails 4+ application.".freeze
  s.email = ["andre@arko.net".freeze]
  s.homepage = "https://github.com/rails/jquery-rails".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Use jQuery with Rails 4+".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<railties>.freeze, [">= 4.2.0"])
    s.add_runtime_dependency(%q<thor>.freeze, [">= 0.14", "< 2.0"])
    s.add_runtime_dependency(%q<rails-dom-testing>.freeze, [">= 1", "< 3"])
  else
    s.add_dependency(%q<railties>.freeze, [">= 4.2.0"])
    s.add_dependency(%q<thor>.freeze, [">= 0.14", "< 2.0"])
    s.add_dependency(%q<rails-dom-testing>.freeze, [">= 1", "< 3"])
  end
end
