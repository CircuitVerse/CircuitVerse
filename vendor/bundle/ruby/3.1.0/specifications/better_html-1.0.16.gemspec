# -*- encoding: utf-8 -*-
# stub: better_html 1.0.16 ruby lib

Gem::Specification.new do |s|
  s.name = "better_html".freeze
  s.version = "1.0.16"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "bug_tracker_uri" => "https://github.com/Shopify/better-html/issues", "changelog_uri" => "https://github.com/Shopify/better-html/releases", "source_code_uri" => "https://github.com/Shopify/better-html/tree/v1.0.16" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Francois Chagnon".freeze]
  s.date = "2021-01-28"
  s.description = "Better HTML for Rails. Provides sane html helpers that make it easier to do the right thing.".freeze
  s.email = ["francois.chagnon@shopify.com".freeze]
  s.homepage = "https://github.com/Shopify/better-html".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Better HTML for Rails.".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<ast>.freeze, ["~> 2.0"])
    s.add_runtime_dependency(%q<erubi>.freeze, ["~> 1.4"])
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 4.0"])
    s.add_runtime_dependency(%q<actionview>.freeze, [">= 4.0"])
    s.add_runtime_dependency(%q<parser>.freeze, [">= 2.4"])
    s.add_runtime_dependency(%q<smart_properties>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<html_tokenizer>.freeze, ["~> 0.0.6"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 0"])
  else
    s.add_dependency(%q<ast>.freeze, ["~> 2.0"])
    s.add_dependency(%q<erubi>.freeze, ["~> 1.4"])
    s.add_dependency(%q<activesupport>.freeze, [">= 4.0"])
    s.add_dependency(%q<actionview>.freeze, [">= 4.0"])
    s.add_dependency(%q<parser>.freeze, [">= 2.4"])
    s.add_dependency(%q<smart_properties>.freeze, [">= 0"])
    s.add_dependency(%q<html_tokenizer>.freeze, ["~> 0.0.6"])
    s.add_dependency(%q<rake>.freeze, ["~> 0"])
  end
end
