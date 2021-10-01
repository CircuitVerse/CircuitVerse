# -*- encoding: utf-8 -*-
# stub: invisible_captcha 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "invisible_captcha".freeze
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Marc Anguera Insa".freeze]
  s.date = "2020-09-01"
  s.description = "Unobtrusive, flexible and simple spam protection for Rails applications using honeypot strategy for better user experience.".freeze
  s.email = ["srmarc.ai@gmail.com".freeze]
  s.homepage = "https://github.com/markets/invisible_captcha".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Simple honeypot protection for RoR apps".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>.freeze, [">= 4.2"])
      s.add_development_dependency(%q<rspec-rails>.freeze, ["~> 3.1"])
      s.add_development_dependency(%q<appraisal>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rails>.freeze, [">= 4.2"])
      s.add_dependency(%q<rspec-rails>.freeze, ["~> 3.1"])
      s.add_dependency(%q<appraisal>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>.freeze, [">= 4.2"])
    s.add_dependency(%q<rspec-rails>.freeze, ["~> 3.1"])
    s.add_dependency(%q<appraisal>.freeze, [">= 0"])
  end
end
