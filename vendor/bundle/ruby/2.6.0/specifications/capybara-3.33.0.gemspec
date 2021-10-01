# -*- encoding: utf-8 -*-
# stub: capybara 3.33.0 ruby lib

Gem::Specification.new do |s|
  s.name = "capybara".freeze
  s.version = "3.33.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/teamcapybara/capybara/blob/master/History.md", "source_code_uri" => "https://github.com/teamcapybara/capybara" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Thomas Walpole".freeze, "Jonas Nicklas".freeze]
  s.cert_chain = ["gem-public_cert.pem".freeze]
  s.date = "2020-06-21"
  s.description = "Capybara is an integration testing tool for rack based web applications. It simulates how a user would interact with a website".freeze
  s.email = ["twalpole@gmail.com".freeze, "jonas.nicklas@gmail.com".freeze]
  s.homepage = "https://github.com/teamcapybara/capybara".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Capybara aims to simplify the process of integration testing Rack applications, such as Rails, Sinatra or Merb".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<addressable>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<mini_mime>.freeze, [">= 0.1.3"])
      s.add_runtime_dependency(%q<nokogiri>.freeze, ["~> 1.8"])
      s.add_runtime_dependency(%q<rack>.freeze, [">= 1.6.0"])
      s.add_runtime_dependency(%q<rack-test>.freeze, [">= 0.6.3"])
      s.add_runtime_dependency(%q<regexp_parser>.freeze, ["~> 1.5"])
      s.add_runtime_dependency(%q<xpath>.freeze, ["~> 3.2"])
      s.add_development_dependency(%q<byebug>.freeze, [">= 0"])
      s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_development_dependency(%q<cucumber>.freeze, [">= 2.3.0"])
      s.add_development_dependency(%q<erubi>.freeze, [">= 0"])
      s.add_development_dependency(%q<irb>.freeze, [">= 0"])
      s.add_development_dependency(%q<launchy>.freeze, [">= 2.0.4"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_development_dependency(%q<puma>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 3.5.0"])
      s.add_development_dependency(%q<rspec-instafail>.freeze, [">= 0"])
      s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.72"])
      s.add_development_dependency(%q<rubocop-performance>.freeze, [">= 0"])
      s.add_development_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<sauce_whisk>.freeze, [">= 0"])
      s.add_development_dependency(%q<selenium-webdriver>.freeze, ["~> 3.5"])
      s.add_development_dependency(%q<selenium_statistics>.freeze, [">= 0"])
      s.add_development_dependency(%q<sinatra>.freeze, [">= 1.4.0"])
      s.add_development_dependency(%q<uglifier>.freeze, [">= 0"])
      s.add_development_dependency(%q<webdrivers>.freeze, [">= 3.6.0"])
      s.add_development_dependency(%q<yard>.freeze, [">= 0.9.0"])
    else
      s.add_dependency(%q<addressable>.freeze, [">= 0"])
      s.add_dependency(%q<mini_mime>.freeze, [">= 0.1.3"])
      s.add_dependency(%q<nokogiri>.freeze, ["~> 1.8"])
      s.add_dependency(%q<rack>.freeze, [">= 1.6.0"])
      s.add_dependency(%q<rack-test>.freeze, [">= 0.6.3"])
      s.add_dependency(%q<regexp_parser>.freeze, ["~> 1.5"])
      s.add_dependency(%q<xpath>.freeze, ["~> 3.2"])
      s.add_dependency(%q<byebug>.freeze, [">= 0"])
      s.add_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_dependency(%q<cucumber>.freeze, [">= 2.3.0"])
      s.add_dependency(%q<erubi>.freeze, [">= 0"])
      s.add_dependency(%q<irb>.freeze, [">= 0"])
      s.add_dependency(%q<launchy>.freeze, [">= 2.0.4"])
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_dependency(%q<puma>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 3.5.0"])
      s.add_dependency(%q<rspec-instafail>.freeze, [">= 0"])
      s.add_dependency(%q<rubocop>.freeze, ["~> 0.72"])
      s.add_dependency(%q<rubocop-performance>.freeze, [">= 0"])
      s.add_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
      s.add_dependency(%q<sauce_whisk>.freeze, [">= 0"])
      s.add_dependency(%q<selenium-webdriver>.freeze, ["~> 3.5"])
      s.add_dependency(%q<selenium_statistics>.freeze, [">= 0"])
      s.add_dependency(%q<sinatra>.freeze, [">= 1.4.0"])
      s.add_dependency(%q<uglifier>.freeze, [">= 0"])
      s.add_dependency(%q<webdrivers>.freeze, [">= 3.6.0"])
      s.add_dependency(%q<yard>.freeze, [">= 0.9.0"])
    end
  else
    s.add_dependency(%q<addressable>.freeze, [">= 0"])
    s.add_dependency(%q<mini_mime>.freeze, [">= 0.1.3"])
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.8"])
    s.add_dependency(%q<rack>.freeze, [">= 1.6.0"])
    s.add_dependency(%q<rack-test>.freeze, [">= 0.6.3"])
    s.add_dependency(%q<regexp_parser>.freeze, ["~> 1.5"])
    s.add_dependency(%q<xpath>.freeze, ["~> 3.2"])
    s.add_dependency(%q<byebug>.freeze, [">= 0"])
    s.add_dependency(%q<coveralls>.freeze, [">= 0"])
    s.add_dependency(%q<cucumber>.freeze, [">= 2.3.0"])
    s.add_dependency(%q<erubi>.freeze, [">= 0"])
    s.add_dependency(%q<irb>.freeze, [">= 0"])
    s.add_dependency(%q<launchy>.freeze, [">= 2.0.4"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<puma>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 3.5.0"])
    s.add_dependency(%q<rspec-instafail>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.72"])
    s.add_dependency(%q<rubocop-performance>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
    s.add_dependency(%q<sauce_whisk>.freeze, [">= 0"])
    s.add_dependency(%q<selenium-webdriver>.freeze, ["~> 3.5"])
    s.add_dependency(%q<selenium_statistics>.freeze, [">= 0"])
    s.add_dependency(%q<sinatra>.freeze, [">= 1.4.0"])
    s.add_dependency(%q<uglifier>.freeze, [">= 0"])
    s.add_dependency(%q<webdrivers>.freeze, [">= 3.6.0"])
    s.add_dependency(%q<yard>.freeze, [">= 0.9.0"])
  end
end
