# -*- encoding: utf-8 -*-
# stub: spring-watcher-listen 2.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "spring-watcher-listen".freeze
  s.version = "2.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jon Leighton".freeze]
  s.date = "2016-10-01"
  s.email = ["j@jonathanleighton.com".freeze]
  s.homepage = "https://github.com/jonleighton/spring-watcher-listen".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Makes spring watch files using the listen gem.".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.6"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<activesupport>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<spring>.freeze, [">= 1.2", "< 3.0"])
      s.add_runtime_dependency(%q<listen>.freeze, [">= 2.7", "< 4.0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.6"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<activesupport>.freeze, [">= 0"])
      s.add_dependency(%q<spring>.freeze, [">= 1.2", "< 3.0"])
      s.add_dependency(%q<listen>.freeze, [">= 2.7", "< 4.0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.6"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<spring>.freeze, [">= 1.2", "< 3.0"])
    s.add_dependency(%q<listen>.freeze, [">= 2.7", "< 4.0"])
  end
end
