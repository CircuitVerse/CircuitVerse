# -*- encoding: utf-8 -*-
# stub: rubocop-rspec 2.11.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rubocop-rspec".freeze
  s.version = "2.11.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/rubocop/rubocop-rspec/blob/master/CHANGELOG.md", "documentation_uri" => "https://docs.rubocop.org/rubocop-rspec/", "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["John Backus".freeze, "Ian MacLeod".freeze, "Nils Gemeinhardt".freeze]
  s.date = "2022-05-18"
  s.description = "    Code style checking for RSpec files.\n    A plugin for the RuboCop code style enforcing & linting tool.\n".freeze
  s.email = ["johncbackus@gmail.com".freeze, "ian@nevir.net".freeze, "git@nilsgemeinhardt.de".freeze]
  s.extra_rdoc_files = ["MIT-LICENSE.md".freeze, "README.md".freeze]
  s.files = ["MIT-LICENSE.md".freeze, "README.md".freeze]
  s.homepage = "https://github.com/rubocop/rubocop-rspec".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.2.32".freeze
  s.summary = "Code style checking for RSpec files".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rubocop>.freeze, ["~> 1.19"])
    s.add_development_dependency(%q<rack>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 3.4"])
    s.add_development_dependency(%q<rubocop-performance>.freeze, ["~> 1.7"])
    s.add_development_dependency(%q<rubocop-rake>.freeze, ["~> 0.6"])
    s.add_development_dependency(%q<yard>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rubocop>.freeze, ["~> 1.19"])
    s.add_dependency(%q<rack>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 3.4"])
    s.add_dependency(%q<rubocop-performance>.freeze, ["~> 1.7"])
    s.add_dependency(%q<rubocop-rake>.freeze, ["~> 0.6"])
    s.add_dependency(%q<yard>.freeze, [">= 0"])
  end
end
