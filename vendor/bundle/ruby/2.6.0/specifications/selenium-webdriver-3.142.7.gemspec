# -*- encoding: utf-8 -*-
# stub: selenium-webdriver 3.142.7 ruby lib

Gem::Specification.new do |s|
  s.name = "selenium-webdriver".freeze
  s.version = "3.142.7"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/SeleniumHQ/selenium/blob/master/rb/CHANGES", "source_code_uri" => "https://github.com/SeleniumHQ/selenium/tree/master/rb" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Alex Rodionov".freeze, "Titus Fortner".freeze, "Thomas Walpole".freeze]
  s.date = "2019-12-27"
  s.description = "WebDriver is a tool for writing automated tests of websites. It aims to mimic the behaviour of a real user, and as such interacts with the HTML of the application.".freeze
  s.email = ["p0deje@gmail.com".freeze, "titusfortner@gmail.com".freeze, "twalpole@gmail.com".freeze]
  s.homepage = "https://github.com/SeleniumHQ/selenium".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "The next generation developer focused tool for automated testing of webapps".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<childprocess>.freeze, [">= 0.5", "< 4.0"])
      s.add_runtime_dependency(%q<rubyzip>.freeze, [">= 1.2.2"])
      s.add_development_dependency(%q<ffi>.freeze, [">= 0"])
      s.add_development_dependency(%q<rack>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.67.0"])
      s.add_development_dependency(%q<rubocop-performance>.freeze, [">= 0"])
      s.add_development_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<webmock>.freeze, ["~> 3.5"])
      s.add_development_dependency(%q<yard>.freeze, ["~> 0.9.11"])
    else
      s.add_dependency(%q<childprocess>.freeze, [">= 0.5", "< 4.0"])
      s.add_dependency(%q<rubyzip>.freeze, [">= 1.2.2"])
      s.add_dependency(%q<ffi>.freeze, [">= 0"])
      s.add_dependency(%q<rack>.freeze, ["~> 2.0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_dependency(%q<rubocop>.freeze, ["~> 0.67.0"])
      s.add_dependency(%q<rubocop-performance>.freeze, [">= 0"])
      s.add_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
      s.add_dependency(%q<webmock>.freeze, ["~> 3.5"])
      s.add_dependency(%q<yard>.freeze, ["~> 0.9.11"])
    end
  else
    s.add_dependency(%q<childprocess>.freeze, [">= 0.5", "< 4.0"])
    s.add_dependency(%q<rubyzip>.freeze, [">= 1.2.2"])
    s.add_dependency(%q<ffi>.freeze, [">= 0"])
    s.add_dependency(%q<rack>.freeze, ["~> 2.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.67.0"])
    s.add_dependency(%q<rubocop-performance>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
    s.add_dependency(%q<webmock>.freeze, ["~> 3.5"])
    s.add_dependency(%q<yard>.freeze, ["~> 0.9.11"])
  end
end
