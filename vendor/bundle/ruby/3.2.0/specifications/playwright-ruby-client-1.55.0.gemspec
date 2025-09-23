# -*- encoding: utf-8 -*-
# stub: playwright-ruby-client 1.55.0 ruby lib

Gem::Specification.new do |s|
  s.name = "playwright-ruby-client".freeze
  s.version = "1.55.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["YusukeIwaki".freeze]
  s.bindir = "exe".freeze
  s.date = "1980-01-02"
  s.email = ["q7w8e9w8q7w8e9@yahoo.co.jp".freeze]
  s.homepage = "https://github.com/YusukeIwaki/playwright-ruby-client".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "The Ruby binding of playwright driver 1.55.0".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<concurrent-ruby>.freeze, [">= 1.1.6"])
  s.add_runtime_dependency(%q<mime-types>.freeze, [">= 3.0"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
  s.add_development_dependency(%q<chunky_png>.freeze, [">= 0"])
  s.add_development_dependency(%q<dry-inflector>.freeze, [">= 0"])
  s.add_development_dependency(%q<faye-websocket>.freeze, [">= 0"])
  s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0"])
  s.add_development_dependency(%q<puma>.freeze, [">= 0"])
  s.add_development_dependency(%q<rack>.freeze, ["< 3"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<sinatra>.freeze, [">= 0"])
end
