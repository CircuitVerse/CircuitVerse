# -*- encoding: utf-8 -*-
# stub: warden 1.2.8 ruby lib

Gem::Specification.new do |s|
  s.name = "warden".freeze
  s.version = "1.2.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Daniel Neighman".freeze, "Justin Smestad".freeze, "Whitney Smestad".freeze, "Jos\u00E9 Valim".freeze]
  s.date = "2018-11-15"
  s.email = "hasox.sox@gmail.com justin.smestad@gmail.com whitcolorado@gmail.com".freeze
  s.extra_rdoc_files = ["LICENSE".freeze, "README.md".freeze]
  s.files = ["LICENSE".freeze, "README.md".freeze]
  s.homepage = "https://github.com/hassox/warden".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.rubygems_version = "3.0.8".freeze
  s.summary = "An authentication library compatible with all Rack-based frameworks".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>.freeze, [">= 2.0.6"])
    else
      s.add_dependency(%q<rack>.freeze, [">= 2.0.6"])
    end
  else
    s.add_dependency(%q<rack>.freeze, [">= 2.0.6"])
  end
end
