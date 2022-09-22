# -*- encoding: utf-8 -*-
# stub: marcel 1.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "marcel".freeze
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tom Ward".freeze]
  s.date = "2021-09-20"
  s.email = ["tom@basecamp.com".freeze]
  s.homepage = "https://github.com/rails/marcel".freeze
  s.licenses = ["MIT".freeze, "Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Simple mime type detection using magic numbers, filenames, and extensions".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.11"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 1.7"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_development_dependency(%q<rack>.freeze, ["~> 2.0"])
    s.add_development_dependency(%q<nokogiri>.freeze, [">= 1.9.1"])
    s.add_development_dependency(%q<byebug>.freeze, ["~> 10.0.2"])
  else
    s.add_dependency(%q<minitest>.freeze, ["~> 5.11"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.7"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_dependency(%q<rack>.freeze, ["~> 2.0"])
    s.add_dependency(%q<nokogiri>.freeze, [">= 1.9.1"])
    s.add_dependency(%q<byebug>.freeze, ["~> 10.0.2"])
  end
end
