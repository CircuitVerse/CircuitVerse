# -*- encoding: utf-8 -*-
# stub: erb_lint 0.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "erb_lint".freeze
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Justin Chan".freeze]
  s.bindir = "exe".freeze
  s.date = "2021-07-28"
  s.description = "ERB Linter tool.".freeze
  s.email = ["justin.the.c@gmail.com".freeze]
  s.executables = ["erblint".freeze]
  s.files = ["exe/erblint".freeze]
  s.homepage = "https://github.com/Shopify/erb-lint".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.2.32".freeze
  s.summary = "ERB lint tool".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<better_html>.freeze, ["~> 1.0.7"])
    s.add_runtime_dependency(%q<html_tokenizer>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<parser>.freeze, [">= 2.7.1.4"])
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<smart_properties>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<rainbow>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_development_dependency(%q<rubocop-shopify>.freeze, [">= 0"])
  else
    s.add_dependency(%q<better_html>.freeze, ["~> 1.0.7"])
    s.add_dependency(%q<html_tokenizer>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_dependency(%q<parser>.freeze, [">= 2.7.1.4"])
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<smart_properties>.freeze, [">= 0"])
    s.add_dependency(%q<rainbow>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop-shopify>.freeze, [">= 0"])
  end
end
