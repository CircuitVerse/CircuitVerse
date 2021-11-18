# -*- encoding: utf-8 -*-
# stub: aws-sessionstore-dynamodb 2.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "aws-sessionstore-dynamodb".freeze
  s.version = "2.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Amazon Web Services".freeze]
  s.date = "2020-11-16"
  s.email = ["mamuller@amazon.com".freeze, "alexwoo@amazon.com".freeze]
  s.homepage = "http://github.com/aws/aws-sessionstore-dynamodb-ruby".freeze
  s.licenses = ["Apache License 2.0".freeze]
  s.rubygems_version = "3.0.8".freeze
  s.summary = "The Amazon DynamoDB Session Store handles sessions for Ruby web applications using a DynamoDB backend.".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<aws-sdk-dynamodb>.freeze, ["~> 1"])
      s.add_runtime_dependency(%q<rack>.freeze, ["~> 2"])
    else
      s.add_dependency(%q<aws-sdk-dynamodb>.freeze, ["~> 1"])
      s.add_dependency(%q<rack>.freeze, ["~> 2"])
    end
  else
    s.add_dependency(%q<aws-sdk-dynamodb>.freeze, ["~> 1"])
    s.add_dependency(%q<rack>.freeze, ["~> 2"])
  end
end
