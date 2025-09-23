# frozen_string_literal: true

require_relative "lib/simplecov/lcov/version"

Gem::Specification.new do |s|
  s.name = "simplecov-lcov".freeze
  s.version = SimpleCov::Lcov::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["fortissimo1997".freeze]
  s.date = Time.now.strftime("%Y-%m-%d")
  s.description = "Custom SimpleCov formatter to generate a lcov style coverage.".freeze
  s.email = "fortissimo1997@gmail.com".freeze
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.markdown"
  ]
  s.files = [
    ".coveralls.yml",
    ".document",
    ".rspec",
    ".tachikoma.yml",
    "Gemfile",
    "LICENSE.txt",
    "README.markdown",
    "Rakefile",
    "lib/simplecov/lcov/version.rb",
    "lib/simple_cov_lcov/configuration.rb",
    "lib/simplecov-lcov.rb",
    "simplecov-lcov.gemspec",
    "spec/configuration_spec.rb",
    "spec/fixtures/app/models/user.rb",
    "spec/fixtures/hoge.rb",
    "spec/fixtures/lcov/spec-fixtures-blank.rb.branch.lcov",
    "spec/fixtures/lcov/spec-fixtures-blank.rb.lcov",
    "spec/fixtures/lcov/spec-fixtures-app-models-user.rb.branch.lcov",
    "spec/fixtures/lcov/spec-fixtures-app-models-user.rb.lcov",
    "spec/fixtures/lcov/spec-fixtures-hoge.rb.branch.lcov",
    "spec/fixtures/lcov/spec-fixtures-hoge.rb.lcov",
    "spec/simplecov-lcov_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/fortissimo1997/simplecov-lcov".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.7.1".freeze
  s.summary = "Custom SimpleCov formatter to generate a lcov style coverage.".freeze

  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<rdoc>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.18"])
  s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
  s.add_development_dependency(%q<activesupport>.freeze, [">= 0"])
end

