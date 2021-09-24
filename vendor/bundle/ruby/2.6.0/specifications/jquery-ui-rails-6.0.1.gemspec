# -*- encoding: utf-8 -*-
# stub: jquery-ui-rails 6.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "jquery-ui-rails".freeze
  s.version = "6.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jo Liss".freeze]
  s.date = "2016-12-01"
  s.description = "jQuery UI's JavaScript, CSS, and image files packaged for the Rails 3.1+ asset pipeline".freeze
  s.email = ["joliss42@gmail.com".freeze]
  s.homepage = "https://github.com/joliss/jquery-ui-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.8".freeze
  s.summary = "jQuery UI packaged for the Rails asset pipeline".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, [">= 3.2.16"])
      s.add_development_dependency(%q<json>.freeze, ["~> 2.0"])
    else
      s.add_dependency(%q<railties>.freeze, [">= 3.2.16"])
      s.add_dependency(%q<json>.freeze, ["~> 2.0"])
    end
  else
    s.add_dependency(%q<railties>.freeze, [">= 3.2.16"])
    s.add_dependency(%q<json>.freeze, ["~> 2.0"])
  end
end
