# -*- encoding: utf-8 -*-
# stub: simplecov-lcov 0.9.0 ruby lib

Gem::Specification.new do |s|
  s.name = "simplecov-lcov".freeze
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["fortissimo1997".freeze]
  s.date = "2025-08-24"
  s.description = "Custom SimpleCov formatter to generate a lcov style coverage.".freeze
  s.email = "fortissimo1997@gmail.com".freeze
  s.extra_rdoc_files = ["LICENSE.txt".freeze, "README.markdown".freeze]
  s.files = ["LICENSE.txt".freeze, "README.markdown".freeze]
  s.homepage = "http://github.com/fortissimo1997/simplecov-lcov".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Custom SimpleCov formatter to generate a lcov style coverage.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<rdoc>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.18"])
  s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
  s.add_development_dependency(%q<activesupport>.freeze, [">= 0"])
end
