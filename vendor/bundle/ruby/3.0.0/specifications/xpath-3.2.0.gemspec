# -*- encoding: utf-8 -*-
# stub: xpath 3.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "xpath".freeze
  s.version = "3.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jonas Nicklas".freeze]
  s.cert_chain = ["gem-public_cert.pem".freeze]
  s.date = "2018-10-15"
  s.description = "XPath is a Ruby DSL for generating XPath expressions".freeze
  s.email = ["jonas.nicklas@gmail.com".freeze]
  s.homepage = "https://github.com/teamcapybara/xpath".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.3.5".freeze
  s.summary = "Generate XPath expressions from Ruby".freeze

  s.installed_by_version = "3.3.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<nokogiri>.freeze, ["~> 1.8"])
    s.add_development_dependency(%q<pry>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<yard>.freeze, [">= 0.5.8"])
  else
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.8"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<yard>.freeze, [">= 0.5.8"])
  end
end
