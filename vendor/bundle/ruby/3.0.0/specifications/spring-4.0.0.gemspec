# -*- encoding: utf-8 -*-
# stub: spring 4.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "spring".freeze
  s.version = "4.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jon Leighton".freeze]
  s.date = "2021-12-10"
  s.description = "Preloads your application so things like console, rake and tests run faster".freeze
  s.email = ["j@jonathanleighton.com".freeze]
  s.executables = ["spring".freeze]
  s.files = ["bin/spring".freeze]
  s.homepage = "https://github.com/rails/spring".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.3.5".freeze
  s.summary = "Rails application preloader".freeze

  s.installed_by_version = "3.3.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<bump>.freeze, [">= 0"])
    s.add_development_dependency(%q<activesupport>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<bump>.freeze, [">= 0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
  end
end
