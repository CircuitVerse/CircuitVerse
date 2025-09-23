# -*- encoding: utf-8 -*-
# stub: capybara 3.40.0 ruby lib

Gem::Specification.new do |s|
  s.name = "capybara".freeze
  s.version = "3.40.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/teamcapybara/capybara/blob/master/History.md", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/teamcapybara/capybara" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Thomas Walpole".freeze, "Jonas Nicklas".freeze]
  s.date = "2024-01-27"
  s.description = "Capybara is an integration testing tool for rack based web applications. It simulates how a user would interact with a website".freeze
  s.email = ["twalpole@gmail.com".freeze, "jonas.nicklas@gmail.com".freeze]
  s.homepage = "https://github.com/teamcapybara/capybara".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Capybara aims to simplify the process of integration testing Rack applications, such as Rails, Sinatra or Merb".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<addressable>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<matrix>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<mini_mime>.freeze, [">= 0.1.3"])
  s.add_runtime_dependency(%q<nokogiri>.freeze, ["~> 1.11"])
  s.add_runtime_dependency(%q<rack>.freeze, [">= 1.6.0"])
  s.add_runtime_dependency(%q<rack-test>.freeze, [">= 0.6.3"])
  s.add_runtime_dependency(%q<regexp_parser>.freeze, [">= 1.5", "< 3.0"])
  s.add_runtime_dependency(%q<xpath>.freeze, ["~> 3.2"])
  s.add_development_dependency(%q<byebug>.freeze, [">= 0"])
  s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
  s.add_development_dependency(%q<cucumber>.freeze, [">= 2.3.0"])
  s.add_development_dependency(%q<erubi>.freeze, [">= 0"])
  s.add_development_dependency(%q<irb>.freeze, [">= 0"])
  s.add_development_dependency(%q<launchy>.freeze, [">= 2.0.4"])
  s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
  s.add_development_dependency(%q<puma>.freeze, [">= 0"])
  s.add_development_dependency(%q<rackup>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 3.5.0"])
  s.add_development_dependency(%q<rspec-instafail>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.1"])
  s.add_development_dependency(%q<rubocop-minitest>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop-performance>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop-rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop-rspec>.freeze, ["~> 2.0"])
  s.add_development_dependency(%q<sauce_whisk>.freeze, [">= 0"])
  s.add_development_dependency(%q<selenium_statistics>.freeze, [">= 0"])
  s.add_development_dependency(%q<selenium-webdriver>.freeze, ["~> 4.8"])
  s.add_development_dependency(%q<sinatra>.freeze, [">= 1.4.0"])
  s.add_development_dependency(%q<uglifier>.freeze, [">= 0"])
  s.add_development_dependency(%q<yard>.freeze, [">= 0.9.0"])
end
