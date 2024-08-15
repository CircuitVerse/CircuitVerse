# -*- encoding: utf-8 -*-
# stub: pr_geohash 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "pr_geohash".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Yuichiro MASUI".freeze]
  s.date = "2009-11-03"
  s.description = "GeoHash encode/decode library for pure Ruby.\n\nIt's implementation of http://en.wikipedia.org/wiki/Geohash".freeze
  s.email = ["masui@masuidrive.jp".freeze]
  s.extra_rdoc_files = ["History.txt".freeze, "Manifest.txt".freeze, "README.rdoc".freeze]
  s.files = ["History.txt".freeze, "Manifest.txt".freeze, "README.rdoc".freeze]
  s.homepage = "http://github.com/masuidrive/pr_geohash".freeze
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "GeoHash encode/decode library for pure Ruby".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<hoe>.freeze, [">= 2.3.3"])
  else
    s.add_dependency(%q<hoe>.freeze, [">= 2.3.3"])
  end
end
