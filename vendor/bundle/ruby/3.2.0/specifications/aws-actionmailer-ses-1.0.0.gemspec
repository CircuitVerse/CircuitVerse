# -*- encoding: utf-8 -*-
# stub: aws-actionmailer-ses 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "aws-actionmailer-ses".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Amazon Web Services".freeze]
  s.date = "2024-11-21"
  s.description = "Amazon Simple Email Service as an ActionMailer delivery method".freeze
  s.email = ["aws-dr-rubygems@amazon.com".freeze]
  s.homepage = "https://github.com/aws/aws-actionmailer-ses-ruby".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7".freeze)
  s.rubygems_version = "3.4.6".freeze
  s.summary = "ActionMailer integration with SES".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<aws-sdk-ses>.freeze, ["~> 1", ">= 1.50.0"])
  s.add_runtime_dependency(%q<aws-sdk-sesv2>.freeze, ["~> 1", ">= 1.34.0"])
  s.add_runtime_dependency(%q<actionmailer>.freeze, [">= 7.1.0"])
end
