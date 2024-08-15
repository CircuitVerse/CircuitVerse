# -*- encoding: utf-8 -*-
# stub: ruby-graphviz 1.2.5 ruby lib

Gem::Specification.new do |s|
  s.name = "ruby-graphviz".freeze
  s.version = "1.2.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Gregoire Lejeune".freeze]
  s.date = "2020-03-05"
  s.description = "Ruby/Graphviz provides an interface to layout and generate images of directed graphs in a variety of formats (PostScript, PNG, etc.) using GraphViz.".freeze
  s.email = "gregoire.lejeune@free.fr".freeze
  s.executables = ["dot2ruby".freeze, "gem2gv".freeze, "git2gv".freeze, "ruby2gv".freeze, "xml2gv".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "COPYING.md".freeze, "CHANGELOG.md".freeze]
  s.files = ["CHANGELOG.md".freeze, "COPYING.md".freeze, "README.md".freeze, "bin/dot2ruby".freeze, "bin/gem2gv".freeze, "bin/git2gv".freeze, "bin/ruby2gv".freeze, "bin/xml2gv".freeze]
  s.homepage = "https://github.com/glejeune/Ruby-Graphviz".freeze
  s.licenses = ["GPL-2.0".freeze]
  s.post_install_message = "\nYou need to install GraphViz (https://graphviz.org) to use this Gem.\n\nFor more information about Ruby-Graphviz :\n* Doc: https://rdoc.info/github/glejeune/Ruby-Graphviz\n* Sources: https://github.com/glejeune/Ruby-Graphviz\n* Issues: https://github.com/glejeune/Ruby-Graphviz/issues\n  ".freeze
  s.rdoc_options = ["--title".freeze, "Ruby/GraphViz".freeze, "--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.requirements = ["GraphViz".freeze]
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Interface to the GraphViz graphing tool".freeze

  s.installed_by_version = "3.3.7" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rexml>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<rdoc>.freeze, [">= 0"])
    s.add_development_dependency(%q<yard>.freeze, [">= 0"])
    s.add_development_dependency(%q<github_changelog_generator>.freeze, [">= 0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<ronn>.freeze, [">= 0"])
    s.add_development_dependency(%q<test-unit>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rexml>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rdoc>.freeze, [">= 0"])
    s.add_dependency(%q<yard>.freeze, [">= 0"])
    s.add_dependency(%q<github_changelog_generator>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<ronn>.freeze, [">= 0"])
    s.add_dependency(%q<test-unit>.freeze, [">= 0"])
  end
end
