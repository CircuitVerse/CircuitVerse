# -*- encoding: utf-8 -*-
# stub: aws-sdk-rails 5.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "aws-sdk-rails".freeze
  s.version = "5.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Amazon Web Services".freeze]
  s.date = "2024-12-05"
  s.description = "Integrates the AWS SDK for Ruby with Ruby on Rails".freeze
  s.email = ["aws-dr-rubygems@amazon.com".freeze]
  s.homepage = "https://github.com/aws/aws-sdk-rails".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "AWS SDK for Ruby on Rails Railtie".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<aws-sdk-core>.freeze, ["~> 3"])
  s.add_runtime_dependency(%q<railties>.freeze, [">= 7.1.0"])
end
