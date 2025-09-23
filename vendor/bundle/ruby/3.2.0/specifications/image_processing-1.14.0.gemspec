# -*- encoding: utf-8 -*-
# stub: image_processing 1.14.0 ruby lib

Gem::Specification.new do |s|
  s.name = "image_processing".freeze
  s.version = "1.14.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/janko/image_processing/blob/master/CHANGELOG.md", "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Janko Marohni\u0107".freeze]
  s.date = "2025-02-10"
  s.description = "High-level wrapper for processing images for the web with ImageMagick or libvips.".freeze
  s.email = ["janko.marohnic@gmail.com".freeze]
  s.homepage = "https://github.com/janko/image_processing".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "High-level wrapper for processing images for the web with ImageMagick or libvips.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<mini_magick>.freeze, [">= 4.9.5", "< 6"])
  s.add_runtime_dependency(%q<ruby-vips>.freeze, [">= 2.0.17", "< 3"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.8"])
  s.add_development_dependency(%q<minitest-hooks>.freeze, [">= 1.4.2"])
  s.add_development_dependency(%q<minispec-metadata>.freeze, [">= 0"])
  s.add_development_dependency(%q<dhash-vips>.freeze, [">= 0"])
end
