# -*- encoding: utf-8 -*-
# stub: rspec_junit_formatter 0.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rspec_junit_formatter".freeze
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 2.0.0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/sj26/rspec_junit_formatter/blob/master/CHANGELOG.md" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Samuel Cochran".freeze]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDKDCCAhCgAwIBAgIBBTANBgkqhkiG9w0BAQUFADA6MQ0wCwYDVQQDDARzajI2\nMRQwEgYKCZImiZPyLGQBGRYEc2oyNjETMBEGCgmSJomT8ixkARkWA2NvbTAeFw0x\nNzA3MzEwNTQ3MDVaFw0xODA3MzEwNTQ3MDVaMDoxDTALBgNVBAMMBHNqMjYxFDAS\nBgoJkiaJk/IsZAEZFgRzajI2MRMwEQYKCZImiZPyLGQBGRYDY29tMIIBIjANBgkq\nhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsr60Eo/ttCk8GMTMFiPr3GoYMIMFvLak\nxSmTk9YGCB6UiEePB4THSSA5w6IPyeaCF/nWkDp3/BAam0eZMWG1IzYQB23TqIM0\n1xzcNRvFsn0aQoQ00k+sj+G83j3T5OOV5OZIlu8xAChMkQmiPd1NXc6uFv+Iacz7\nkj+CMsI9YUFdNoU09QY0b+u+Rb6wDYdpyvN60YC30h0h1MeYbvYZJx/iZK4XY5zu\n4O/FL2ChjL2CPCpLZW55ShYyrzphWJwLOJe+FJ/ZBl6YXwrzQM9HKnt4titSNvyU\nKzE3L63A3PZvExzLrN9u09kuWLLJfXB2sGOlw3n9t72rJiuBr3/OQQIDAQABozkw\nNzAJBgNVHRMEAjAAMAsGA1UdDwQEAwIEsDAdBgNVHQ4EFgQU99dfRjEKFyczTeIz\nm3ZsDWrNC80wDQYJKoZIhvcNAQEFBQADggEBADGiXpvK754s0zTFx3y31ZRDdvAI\nlA209JIjUlDyr9ptCRadihyfF2l9/hb+hLemiPEYppzG6vEK1TIyzbAR36yOJ8CX\n4vPkCXLuwHhs6UIRbwN+IEy41nsIlBxmjLYei8h3t/G2Vm2oOaLdbjDXS+Srl9U8\nshsE8ft81PxSQfzEL7Mr9cC9XvWbHW+SyTpfGm8rAtaqZkNeke4U8a0di4oz2EfA\nP4lSfmXxsd1C71ckIp0cyXkPhyTtpyS/5hq9HhuUNzEHkSDe36/Rd1xYKV5JxMC2\nYAttWFUs06lor2q1wwncPaMtUtbWwW35+1IV6xhs2rFY6DD/I6ZkK3GnHdY=\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2018-05-30"
  s.description = "RSpec results that your continuous integration service can read.".freeze
  s.email = "sj26@sj26.com".freeze
  s.homepage = "http://github.com/sj26/rspec_junit_formatter".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "RSpec JUnit XML formatter".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
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
  else
    s.add_dependency(%q<rspec-core>.freeze, [">= 2", "< 4", "!= 2.12.0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<appraisal>.freeze, [">= 0"])
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.8", ">= 1.8.2"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<coderay>.freeze, [">= 0"])
  end
end
