# -*- encoding: utf-8 -*-
# stub: aws-sdk-rails 3.6.2 ruby lib

Gem::Specification.new do |s|
  s.name = "aws-sdk-rails".freeze
  s.version = "3.6.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Amazon Web Services".freeze]
  s.date = "2022-06-16"
  s.description = "Integrates the AWS Ruby SDK with Ruby on Rails".freeze
  s.email = ["mamuller@amazon.com".freeze, "alexwoo@amazon.com".freeze]
  s.executables = ["aws_sqs_active_job".freeze]
  s.files = ["bin/aws_sqs_active_job".freeze]
  s.homepage = "https://github.com/aws/aws-sdk-rails".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.rubygems_version = "3.2.32".freeze
  s.summary = "AWS SDK for Ruby on Rails Plugin".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<aws-record>.freeze, ["~> 2"])
    s.add_runtime_dependency(%q<aws-sdk-ses>.freeze, ["~> 1"])
    s.add_runtime_dependency(%q<aws-sdk-sqs>.freeze, ["~> 1"])
    s.add_runtime_dependency(%q<aws-sessionstore-dynamodb>.freeze, ["~> 2"])
    s.add_runtime_dependency(%q<railties>.freeze, [">= 5.2.0"])
    s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1"])
    s.add_development_dependency(%q<rails>.freeze, [">= 0"])
  else
    s.add_dependency(%q<aws-record>.freeze, ["~> 2"])
    s.add_dependency(%q<aws-sdk-ses>.freeze, ["~> 1"])
    s.add_dependency(%q<aws-sdk-sqs>.freeze, ["~> 1"])
    s.add_dependency(%q<aws-sessionstore-dynamodb>.freeze, ["~> 2"])
    s.add_dependency(%q<railties>.freeze, [">= 5.2.0"])
    s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1"])
    s.add_dependency(%q<rails>.freeze, [">= 0"])
  end
end
