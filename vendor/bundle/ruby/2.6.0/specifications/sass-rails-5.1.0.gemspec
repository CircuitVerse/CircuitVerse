# -*- encoding: utf-8 -*-
# stub: sass-rails 5.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "sass-rails".freeze
  s.version = "5.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["wycats".freeze, "chriseppstein".freeze]
  s.date = "2019-08-16"
  s.description = "Sass adapter for the Rails asset pipeline.".freeze
  s.email = ["wycats@gmail.com".freeze, "chris@eppsteins.net".freeze]
  s.homepage = "https://github.com/rails/sass-rails".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Sass adapter for the Rails asset pipeline.".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, [">= 5.2.0"])
      s.add_runtime_dependency(%q<sass>.freeze, ["~> 3.1"])
      s.add_runtime_dependency(%q<sprockets-rails>.freeze, [">= 2.0", "< 4.0"])
      s.add_runtime_dependency(%q<sprockets>.freeze, [">= 2.8", "< 4.0"])
      s.add_runtime_dependency(%q<tilt>.freeze, [">= 1.1", "< 3"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
    else
      s.add_dependency(%q<railties>.freeze, [">= 5.2.0"])
      s.add_dependency(%q<sass>.freeze, ["~> 3.1"])
      s.add_dependency(%q<sprockets-rails>.freeze, [">= 2.0", "< 4.0"])
      s.add_dependency(%q<sprockets>.freeze, [">= 2.8", "< 4.0"])
      s.add_dependency(%q<tilt>.freeze, [">= 1.1", "< 3"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<railties>.freeze, [">= 5.2.0"])
    s.add_dependency(%q<sass>.freeze, ["~> 3.1"])
    s.add_dependency(%q<sprockets-rails>.freeze, [">= 2.0", "< 4.0"])
    s.add_dependency(%q<sprockets>.freeze, [">= 2.8", "< 4.0"])
    s.add_dependency(%q<tilt>.freeze, [">= 1.1", "< 3"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
  end
end
