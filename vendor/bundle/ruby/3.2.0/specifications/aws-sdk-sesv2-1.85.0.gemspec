# -*- encoding: utf-8 -*-
# stub: aws-sdk-sesv2 1.85.0 ruby lib

Gem::Specification.new do |s|
  s.name = "aws-sdk-sesv2".freeze
  s.version = "1.85.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/aws/aws-sdk-ruby/tree/version-3/gems/aws-sdk-sesv2/CHANGELOG.md", "source_code_uri" => "https://github.com/aws/aws-sdk-ruby/tree/version-3/gems/aws-sdk-sesv2" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Amazon Web Services".freeze]
  s.date = "1980-01-02"
  s.description = "Official AWS Ruby gem for Amazon Simple Email Service (Amazon SES V2). This gem is part of the AWS SDK for Ruby.".freeze
  s.email = ["aws-dr-rubygems@amazon.com".freeze]
  s.homepage = "https://github.com/aws/aws-sdk-ruby".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "AWS SDK for Ruby - Amazon SES V2".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<aws-sdk-core>.freeze, ["~> 3", ">= 3.231.0"])
  s.add_runtime_dependency(%q<aws-sigv4>.freeze, ["~> 1.5"])
end
