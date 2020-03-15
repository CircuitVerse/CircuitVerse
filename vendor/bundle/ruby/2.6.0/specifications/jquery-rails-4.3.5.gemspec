# -*- encoding: utf-8 -*-
# stub: jquery-rails 4.3.5 ruby lib

Gem::Specification.new do |s|
  s.name = "jquery-rails".freeze
  s.version = "4.3.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andr\u00E9 Arko".freeze]
  s.date = "2019-06-13"
  s.description = "This gem provides jQuery and the jQuery-ujs driver for your Rails 4+ application.".freeze
  s.email = ["andre@arko.net".freeze]
  s.homepage = "https://github.com/rails/jquery-rails".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Use jQuery with Rails 4+".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, [">= 4.2.0"])
      s.add_runtime_dependency(%q<thor>.freeze, [">= 0.14", "< 2.0"])
      s.add_runtime_dependency(%q<rails-dom-testing>.freeze, [">= 1", "< 3"])
    else
      s.add_dependency(%q<railties>.freeze, [">= 4.2.0"])
      s.add_dependency(%q<thor>.freeze, [">= 0.14", "< 2.0"])
      s.add_dependency(%q<rails-dom-testing>.freeze, [">= 1", "< 3"])
    end
  else
    s.add_dependency(%q<railties>.freeze, [">= 4.2.0"])
    s.add_dependency(%q<thor>.freeze, [">= 0.14", "< 2.0"])
    s.add_dependency(%q<rails-dom-testing>.freeze, [">= 1", "< 3"])
  end
end
