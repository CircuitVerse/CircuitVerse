# -*- encoding: utf-8 -*-
# stub: faker 2.14.0 ruby lib

Gem::Specification.new do |s|
  s.name = "faker".freeze
  s.version = "2.14.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/faker-ruby/faker/issues", "changelog_uri" => "https://github.com/faker-ruby/faker/blob/master/CHANGELOG.md", "documentation_uri" => "https://rubydoc.info/github/faker-ruby/faker/master", "source_code_uri" => "https://github.com/faker-ruby/faker", "yard.run" => "yri" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Benjamin Curtis".freeze, "Vitor Oliveira".freeze]
  s.date = "2020-09-16"
  s.description = "Faker, a port of Data::Faker from Perl, is used to easily generate fake data: names, addresses, phone numbers, etc.".freeze
  s.email = ["benjamin.curtis@gmail.com".freeze, "vbrazo@gmail.com".freeze]
  s.executables = ["faker".freeze]
  s.files = ["bin/faker".freeze]
  s.homepage = "https://github.com/faker-ruby/faker".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Easily generate fake data".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<i18n>.freeze, [">= 1.6", "< 2"])
      s.add_development_dependency(%q<minitest>.freeze, ["= 5.14.2"])
      s.add_development_dependency(%q<pry>.freeze, ["= 0.13.1"])
      s.add_development_dependency(%q<rake>.freeze, ["= 13.0.1"])
      s.add_development_dependency(%q<rubocop>.freeze, ["= 0.90.0"])
      s.add_development_dependency(%q<simplecov>.freeze, ["= 0.17.1"])
      s.add_development_dependency(%q<test-unit>.freeze, ["= 3.3.6"])
      s.add_development_dependency(%q<timecop>.freeze, ["= 0.9.1"])
      s.add_development_dependency(%q<yard>.freeze, ["= 0.9.25"])
    else
      s.add_dependency(%q<i18n>.freeze, [">= 1.6", "< 2"])
      s.add_dependency(%q<minitest>.freeze, ["= 5.14.2"])
      s.add_dependency(%q<pry>.freeze, ["= 0.13.1"])
      s.add_dependency(%q<rake>.freeze, ["= 13.0.1"])
      s.add_dependency(%q<rubocop>.freeze, ["= 0.90.0"])
      s.add_dependency(%q<simplecov>.freeze, ["= 0.17.1"])
      s.add_dependency(%q<test-unit>.freeze, ["= 3.3.6"])
      s.add_dependency(%q<timecop>.freeze, ["= 0.9.1"])
      s.add_dependency(%q<yard>.freeze, ["= 0.9.25"])
    end
  else
    s.add_dependency(%q<i18n>.freeze, [">= 1.6", "< 2"])
    s.add_dependency(%q<minitest>.freeze, ["= 5.14.2"])
    s.add_dependency(%q<pry>.freeze, ["= 0.13.1"])
    s.add_dependency(%q<rake>.freeze, ["= 13.0.1"])
    s.add_dependency(%q<rubocop>.freeze, ["= 0.90.0"])
    s.add_dependency(%q<simplecov>.freeze, ["= 0.17.1"])
    s.add_dependency(%q<test-unit>.freeze, ["= 3.3.6"])
    s.add_dependency(%q<timecop>.freeze, ["= 0.9.1"])
    s.add_dependency(%q<yard>.freeze, ["= 0.9.25"])
  end
end
