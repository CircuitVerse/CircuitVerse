# -*- encoding: utf-8 -*-
# stub: hashdiff 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "hashdiff".freeze
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/liufengyun/hashdiff/issues", "changelog_uri" => "https://github.com/liufengyun/hashdiff/blob/master/changelog.md", "documentation_uri" => "https://www.rubydoc.info/gems/hashdiff", "homepage_uri" => "https://github.com/liufengyun/hashdiff", "source_code_uri" => "https://github.com/liufengyun/hashdiff" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Liu Fengyun".freeze]
  s.date = "2020-02-27"
  s.description = " Hashdiff is a diff lib to compute the smallest difference between two hashes. ".freeze
  s.email = ["liufengyunchina@gmail.com".freeze]
  s.homepage = "https://github.com/liufengyun/hashdiff".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Hashdiff is a diff lib to compute the smallest difference between two hashes.".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bluecloth>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.49.1"])
      s.add_development_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<yard>.freeze, [">= 0"])
    else
      s.add_dependency(%q<bluecloth>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 2.0"])
      s.add_dependency(%q<rubocop>.freeze, ["~> 0.49.1"])
      s.add_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
      s.add_dependency(%q<yard>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<bluecloth>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 2.0"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.49.1"])
    s.add_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
    s.add_dependency(%q<yard>.freeze, [">= 0"])
  end
end
