# -*- encoding: utf-8 -*-
# stub: jwt 2.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "jwt".freeze
  s.version = "2.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tim Rudat".freeze]
  s.date = "2019-05-24"
  s.description = "A pure ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT) standard.".freeze
  s.email = "timrudat@gmail.com".freeze
  s.homepage = "https://github.com/jwt/ruby-jwt".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "JSON Web Token implementation in Ruby".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<appraisal>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov-json>.freeze, [">= 0"])
      s.add_development_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0"])
      s.add_development_dependency(%q<codacy-coverage>.freeze, [">= 0"])
      s.add_development_dependency(%q<rbnacl>.freeze, [">= 0"])
      s.add_development_dependency(%q<openssl>.freeze, ["~> 2.1"])
    else
      s.add_dependency(%q<appraisal>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov-json>.freeze, [">= 0"])
      s.add_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0"])
      s.add_dependency(%q<codacy-coverage>.freeze, [">= 0"])
      s.add_dependency(%q<rbnacl>.freeze, [">= 0"])
      s.add_dependency(%q<openssl>.freeze, ["~> 2.1"])
    end
  else
    s.add_dependency(%q<appraisal>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov-json>.freeze, [">= 0"])
    s.add_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0"])
    s.add_dependency(%q<codacy-coverage>.freeze, [">= 0"])
    s.add_dependency(%q<rbnacl>.freeze, [">= 0"])
    s.add_dependency(%q<openssl>.freeze, ["~> 2.1"])
  end
end
