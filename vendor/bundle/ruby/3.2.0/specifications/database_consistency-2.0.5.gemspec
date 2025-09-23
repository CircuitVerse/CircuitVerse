# -*- encoding: utf-8 -*-
# stub: database_consistency 2.0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "database_consistency".freeze
  s.version = "2.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "funding_uri" => "https://opencollective.com/database_consistency#support" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Evgeniy Demin".freeze]
  s.date = "2025-08-22"
  s.email = ["lawliet.djez@gmail.com".freeze]
  s.executables = ["database_consistency".freeze]
  s.files = ["bin/database_consistency".freeze]
  s.homepage = "https://github.com/djezzzl/database_consistency".freeze
  s.licenses = ["MIT".freeze]
  s.post_install_message = "\nThank you for using the gem!\n\nIf the project helps you or your organization, I would be very grateful if you contribute or donate.\nYour support is an incredible motivation and the biggest reward for my hard work.\n\nhttps://github.com/djezzzl/database_consistency#contributing\nhttps://opencollective.com/database_consistency#support\n\nThank you for your attention,\nEvgeniy Demin\n\n".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Provide an easy way to check the consistency of the database constraints with the application validations.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 3.2"])
  s.add_development_dependency(%q<bundler>.freeze, ["> 1.16"])
  s.add_development_dependency(%q<mysql2>.freeze, ["~> 0.5"])
  s.add_development_dependency(%q<pg>.freeze, [">= 0.2"])
  s.add_development_dependency(%q<rake>.freeze, [">= 12.3.3"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  s.add_development_dependency(%q<rspec_junit_formatter>.freeze, ["~> 0.4"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.55"])
  s.add_development_dependency(%q<sqlite3>.freeze, ["> 1.3"])
end
