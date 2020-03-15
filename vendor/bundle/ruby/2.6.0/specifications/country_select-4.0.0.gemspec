# -*- encoding: utf-8 -*-
# stub: country_select 4.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "country_select".freeze
  s.version = "4.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Stefan Penner".freeze]
  s.date = "2018-12-20"
  s.description = "Provides a simple helper to get an HTML select list of countries.  The list of countries comes from the ISO 3166 standard.  While it is a relatively neutral source of country names, it will still offend some users.".freeze
  s.email = ["stefan.penner@gmail.com".freeze]
  s.homepage = "https://github.com/stefanpenner/country_select".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Country Select Plugin".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<actionpack>.freeze, ["~> 5"])
      s.add_development_dependency(%q<pry>.freeze, ["~> 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3"])
      s.add_development_dependency(%q<wwtd>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<countries>.freeze, ["~> 3.0"])
      s.add_runtime_dependency(%q<sort_alphabetical>.freeze, ["~> 1.0"])
    else
      s.add_dependency(%q<actionpack>.freeze, ["~> 5"])
      s.add_dependency(%q<pry>.freeze, ["~> 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3"])
      s.add_dependency(%q<wwtd>.freeze, [">= 0"])
      s.add_dependency(%q<countries>.freeze, ["~> 3.0"])
      s.add_dependency(%q<sort_alphabetical>.freeze, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<actionpack>.freeze, ["~> 5"])
    s.add_dependency(%q<pry>.freeze, ["~> 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3"])
    s.add_dependency(%q<wwtd>.freeze, [">= 0"])
    s.add_dependency(%q<countries>.freeze, ["~> 3.0"])
    s.add_dependency(%q<sort_alphabetical>.freeze, ["~> 1.0"])
  end
end
