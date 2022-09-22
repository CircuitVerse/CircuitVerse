# -*- encoding: utf-8 -*-
# stub: rails-data-migrations 1.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rails-data-migrations".freeze
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Sergey Glukhov".freeze]
  s.date = "2019-09-12"
  s.email = ["sergey.glukhov@gmail.com".freeze]
  s.homepage = "https://github.com/OffgridElectric/rails-data-migrations".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Run your data migration tasks in a db:migrate-like manner".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rails>.freeze, [">= 4.0.0"])
    s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.1"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.13"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["= 3.5.0"])
    s.add_development_dependency(%q<rubocop>.freeze, ["= 0.52.1"])
    s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.3"])
  else
    s.add_dependency(%q<rails>.freeze, [">= 4.0.0"])
    s.add_dependency(%q<appraisal>.freeze, ["~> 2.1"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.13"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["= 3.5.0"])
    s.add_dependency(%q<rubocop>.freeze, ["= 0.52.1"])
    s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3"])
  end
end
