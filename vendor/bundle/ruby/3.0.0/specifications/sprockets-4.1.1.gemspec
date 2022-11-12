# -*- encoding: utf-8 -*-
# stub: sprockets 4.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "sprockets".freeze
  s.version = "4.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Sam Stephenson".freeze, "Joshua Peek".freeze]
  s.date = "2022-06-27"
  s.description = "Sprockets is a Rack-based asset packaging system that concatenates and serves JavaScript, CoffeeScript, CSS, Sass, and SCSS.".freeze
  s.email = ["sstephenson@gmail.com".freeze, "josh@joshpeek.com".freeze]
  s.executables = ["sprockets".freeze]
  s.files = ["bin/sprockets".freeze]
  s.homepage = "https://github.com/rails/sprockets".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.2.32".freeze
  s.summary = "Rack-based asset packaging system".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rack>.freeze, ["> 1", "< 3"])
    s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<m>.freeze, [">= 0"])
    s.add_development_dependency(%q<babel-transpiler>.freeze, ["~> 0.6"])
    s.add_development_dependency(%q<closure-compiler>.freeze, ["~> 1.1"])
    s.add_development_dependency(%q<coffee-script-source>.freeze, ["~> 1.6"])
    s.add_development_dependency(%q<coffee-script>.freeze, ["~> 2.2"])
    s.add_development_dependency(%q<eco>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<ejs>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<execjs>.freeze, ["~> 2.0"])
    s.add_development_dependency(%q<jsminc>.freeze, ["~> 1.1"])
    s.add_development_dependency(%q<timecop>.freeze, ["~> 0.9.1"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_development_dependency(%q<nokogiri>.freeze, ["~> 1.3"])
    s.add_development_dependency(%q<rack-test>.freeze, ["~> 0.6"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 12.0"])
    s.add_development_dependency(%q<sass>.freeze, ["~> 3.4"])
    s.add_development_dependency(%q<sassc>.freeze, ["~> 2.0"])
    s.add_development_dependency(%q<uglifier>.freeze, [">= 2.3"])
    s.add_development_dependency(%q<yui-compressor>.freeze, ["~> 0.12"])
    s.add_development_dependency(%q<zopfli>.freeze, ["~> 0.0.4"])
    s.add_development_dependency(%q<rubocop-performance>.freeze, ["~> 1.3"])
  else
    s.add_dependency(%q<rack>.freeze, ["> 1", "< 3"])
    s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
    s.add_dependency(%q<m>.freeze, [">= 0"])
    s.add_dependency(%q<babel-transpiler>.freeze, ["~> 0.6"])
    s.add_dependency(%q<closure-compiler>.freeze, ["~> 1.1"])
    s.add_dependency(%q<coffee-script-source>.freeze, ["~> 1.6"])
    s.add_dependency(%q<coffee-script>.freeze, ["~> 2.2"])
    s.add_dependency(%q<eco>.freeze, ["~> 1.0"])
    s.add_dependency(%q<ejs>.freeze, ["~> 1.0"])
    s.add_dependency(%q<execjs>.freeze, ["~> 2.0"])
    s.add_dependency(%q<jsminc>.freeze, ["~> 1.1"])
    s.add_dependency(%q<timecop>.freeze, ["~> 0.9.1"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rack-test>.freeze, ["~> 0.6"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.0"])
    s.add_dependency(%q<sass>.freeze, ["~> 3.4"])
    s.add_dependency(%q<sassc>.freeze, ["~> 2.0"])
    s.add_dependency(%q<uglifier>.freeze, [">= 2.3"])
    s.add_dependency(%q<yui-compressor>.freeze, ["~> 0.12"])
    s.add_dependency(%q<zopfli>.freeze, ["~> 0.0.4"])
    s.add_dependency(%q<rubocop-performance>.freeze, ["~> 1.3"])
  end
end
