# -*- encoding: utf-8 -*-
# stub: rails_admin 3.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rails_admin".freeze
  s.version = "3.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.8.11".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Erik Michaels-Ober".freeze, "Bogdan Gaza".freeze, "Petteri Kaapa".freeze, "Benoit Benezech".freeze, "Mitsuhiro Shibuya".freeze]
  s.date = "2024-12-08"
  s.description = "RailsAdmin is a Rails engine that provides an easy-to-use interface for managing your data.".freeze
  s.email = ["sferik@gmail.com".freeze, "bogdan@cadmio.org".freeze, "petteri.kaapa@gmail.com".freeze]
  s.homepage = "https://github.com/railsadminteam/rails_admin".freeze
  s.licenses = ["MIT".freeze]
  s.post_install_message = "### Upgrading RailsAdmin from 2.x.x to 3.x.x ###\n\nDue to introduction of Webpack/Webpacker support, some additional dependencies and configuration will be needed.\nRunning `bin/rails g rails_admin:install` will suggest required changes, based on the current setup of your app.\n\nFor a complete list of changes, see https://github.com/railsadminteam/rails_admin/blob/master/CHANGELOG.md\n".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Admin for Rails".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activemodel-serializers-xml>.freeze, [">= 1.0"])
  s.add_runtime_dependency(%q<csv>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<kaminari>.freeze, [">= 0.14", "< 2.0"])
  s.add_runtime_dependency(%q<nested_form>.freeze, ["~> 0.3"])
  s.add_runtime_dependency(%q<rails>.freeze, [">= 6.0", "< 9"])
  s.add_runtime_dependency(%q<turbo-rails>.freeze, [">= 1.0", "< 3"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 1.0"])
end
