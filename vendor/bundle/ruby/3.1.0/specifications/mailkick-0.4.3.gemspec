# -*- encoding: utf-8 -*-
# stub: mailkick 0.4.3 ruby lib

Gem::Specification.new do |s|
  s.name = "mailkick".freeze
  s.version = "0.4.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andrew Kane".freeze]
  s.date = "2020-11-01"
  s.email = "andrew@chartkick.com".freeze
  s.homepage = "https://github.com/ankane/mailkick".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4".freeze)
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Email unsubscribes for Rails".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<gibbon>.freeze, [">= 2"])
    s.add_development_dependency(%q<mailgun-ruby>.freeze, [">= 0"])
    s.add_development_dependency(%q<mandrill-api>.freeze, [">= 0"])
    s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<sendgrid_toolkit>.freeze, [">= 0"])
    s.add_development_dependency(%q<postmark>.freeze, [">= 0"])
    s.add_development_dependency(%q<combustion>.freeze, [">= 0"])
    s.add_development_dependency(%q<rails>.freeze, [">= 0"])
    s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 5"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<gibbon>.freeze, [">= 2"])
    s.add_dependency(%q<mailgun-ruby>.freeze, [">= 0"])
    s.add_dependency(%q<mandrill-api>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<sendgrid_toolkit>.freeze, [">= 0"])
    s.add_dependency(%q<postmark>.freeze, [">= 0"])
    s.add_dependency(%q<combustion>.freeze, [">= 0"])
    s.add_dependency(%q<rails>.freeze, [">= 0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
  end
end
