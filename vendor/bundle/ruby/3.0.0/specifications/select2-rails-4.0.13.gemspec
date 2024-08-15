# -*- encoding: utf-8 -*-
# stub: select2-rails 4.0.13 ruby lib

Gem::Specification.new do |s|
  s.name = "select2-rails".freeze
  s.version = "4.0.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Rogerio Medeiros".freeze, "Pedro Nascimento".freeze]
  s.date = "2020-07-10"
  s.description = "Select2 is a jQuery based replacement for select boxes. It supports searching, remote data sets, and infinite scrolling of results. This gem integrates Select2 with Rails asset pipeline for easy of use.".freeze
  s.email = ["argerim@gmail.com".freeze, "pnascimento@gmail.com".freeze]
  s.homepage = "https://github.com/argerim/select2-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.32".freeze
  s.summary = "Integrate Select2 javascript library with Rails asset pipeline".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<thor>.freeze, ["~> 1"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<rails>.freeze, [">= 3.0"])
    s.add_development_dependency(%q<httpclient>.freeze, ["~> 2.2"])
  else
    s.add_dependency(%q<thor>.freeze, ["~> 1"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rails>.freeze, [">= 3.0"])
    s.add_dependency(%q<httpclient>.freeze, ["~> 2.2"])
  end
end
