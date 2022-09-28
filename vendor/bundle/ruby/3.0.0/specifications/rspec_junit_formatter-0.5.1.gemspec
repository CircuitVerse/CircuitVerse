# -*- encoding: utf-8 -*-
# stub: rspec_junit_formatter 0.5.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rspec_junit_formatter".freeze
  s.version = "0.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 2.0.0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/sj26/rspec_junit_formatter/blob/HEAD/CHANGELOG.md" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Samuel Cochran".freeze]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDKDCCAhCgAwIBAgIBCDANBgkqhkiG9w0BAQsFADA6MQ0wCwYDVQQDDARzajI2\nMRQwEgYKCZImiZPyLGQBGRYEc2oyNjETMBEGCgmSJomT8ixkARkWA2NvbTAeFw0y\nMTA0MjcwMzIxMjZaFw0yMjA0MjcwMzIxMjZaMDoxDTALBgNVBAMMBHNqMjYxFDAS\nBgoJkiaJk/IsZAEZFgRzajI2MRMwEQYKCZImiZPyLGQBGRYDY29tMIIBIjANBgkq\nhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsr60Eo/ttCk8GMTMFiPr3GoYMIMFvLak\nxSmTk9YGCB6UiEePB4THSSA5w6IPyeaCF/nWkDp3/BAam0eZMWG1IzYQB23TqIM0\n1xzcNRvFsn0aQoQ00k+sj+G83j3T5OOV5OZIlu8xAChMkQmiPd1NXc6uFv+Iacz7\nkj+CMsI9YUFdNoU09QY0b+u+Rb6wDYdpyvN60YC30h0h1MeYbvYZJx/iZK4XY5zu\n4O/FL2ChjL2CPCpLZW55ShYyrzphWJwLOJe+FJ/ZBl6YXwrzQM9HKnt4titSNvyU\nKzE3L63A3PZvExzLrN9u09kuWLLJfXB2sGOlw3n9t72rJiuBr3/OQQIDAQABozkw\nNzAJBgNVHRMEAjAAMAsGA1UdDwQEAwIEsDAdBgNVHQ4EFgQU99dfRjEKFyczTeIz\nm3ZsDWrNC80wDQYJKoZIhvcNAQELBQADggEBAInkmTwBeGEJ7Xu9jjZIuFaE197m\nYfvrzVoE6Q1DlWXpgyhhxbPIKg2acvM/Z18A7kQrF7paYl64Ti84dC64seOFIBNx\nQj/lxzPHMBoAYqeXYJhnYIXnvGCZ4Fkic5Bhs+VdcDP/uwYp3adqy+4bT/XDFZQg\ntSjrAOTg3wck5aI+Tz90ONQJ83bnCRr1UPQ0T3PbWMjnNsEa9CAxUB845Sg+9yUz\nTvf+pbX8JT9rawFDogxPhL7eRAbjg4MH9amp5l8HTVCAsW8vqv7wM4rtMNAaXmik\nLJghfDEf70fTtbs4Zv57pPhn1b7wBNf8fh+TZOlYAA6dFtQXoCwfE6bWgQU=\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2022-01-06"
  s.description = "RSpec results that your continuous integration service can read.".freeze
  s.email = "sj26@sj26.com".freeze
  s.homepage = "https://github.com/sj26/rspec_junit_formatter".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.2.32".freeze
  s.summary = "RSpec JUnit XML formatter".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rspec-core>.freeze, [">= 2", "< 4", "!= 2.12.0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<appraisal>.freeze, [">= 0"])
    s.add_development_dependency(%q<nokogiri>.freeze, ["~> 1.8", ">= 1.8.2"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<coderay>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rspec-core>.freeze, [">= 2", "< 4", "!= 2.12.0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<appraisal>.freeze, [">= 0"])
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.8", ">= 1.8.2"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<coderay>.freeze, [">= 0"])
  end
end
