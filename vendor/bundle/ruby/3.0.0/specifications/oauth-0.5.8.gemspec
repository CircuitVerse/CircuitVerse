# -*- encoding: utf-8 -*-
# stub: oauth 0.5.8 ruby lib

Gem::Specification.new do |s|
  s.name = "oauth".freeze
  s.version = "0.5.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/oauth-xx/oauth-ruby/issues", "changelog_uri" => "https://github.com/oauth-xx/oauth-ruby/blob/master/CHANGELOG.md", "documentation_uri" => "https://rubydoc.info/github/oauth-xx/oauth-ruby/master", "homepage_uri" => "https://github.com/oauth-xx/oauth-ruby", "source_code_uri" => "https://github.com/oauth-xx/oauth-ruby" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Pelle Braendgaard".freeze, "Blaine Cook".freeze, "Larry Halff".freeze, "Jesse Clark".freeze, "Jon Crosby".freeze, "Seth Fitzsimmons".freeze, "Matt Sanford".freeze, "Aaron Quint".freeze, "Peter Boling".freeze]
  s.date = "2021-11-10"
  s.email = "oauth-ruby@googlegroups.com".freeze
  s.executables = ["oauth".freeze]
  s.extra_rdoc_files = ["TODO".freeze]
  s.files = ["TODO".freeze, "bin/oauth".freeze]
  s.homepage = "https://github.com/oauth-xx/oauth-ruby".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0".freeze)
  s.rubygems_version = "3.2.32".freeze
  s.summary = "OAuth Core Ruby implementation".freeze

  s.installed_by_version = "3.2.32" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<actionpack>.freeze, [">= 5.0"])
    s.add_development_dependency(%q<curb>.freeze, [">= 0"])
    s.add_development_dependency(%q<em-http-request>.freeze, ["~> 1.1.7"])
    s.add_development_dependency(%q<iconv>.freeze, [">= 0"])
    s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_development_dependency(%q<mocha>.freeze, [">= 0"])
    s.add_development_dependency(%q<rack>.freeze, ["~> 2.0"])
    s.add_development_dependency(%q<rack-test>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_development_dependency(%q<rest-client>.freeze, [">= 0"])
    s.add_development_dependency(%q<typhoeus>.freeze, [">= 0.1.13"])
    s.add_development_dependency(%q<webmock>.freeze, ["<= 3.14.0"])
  else
    s.add_dependency(%q<actionpack>.freeze, [">= 5.0"])
    s.add_dependency(%q<curb>.freeze, [">= 0"])
    s.add_dependency(%q<em-http-request>.freeze, ["~> 1.1.7"])
    s.add_dependency(%q<iconv>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<mocha>.freeze, [">= 0"])
    s.add_dependency(%q<rack>.freeze, ["~> 2.0"])
    s.add_dependency(%q<rack-test>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_dependency(%q<rest-client>.freeze, [">= 0"])
    s.add_dependency(%q<typhoeus>.freeze, [">= 0.1.13"])
    s.add_dependency(%q<webmock>.freeze, ["<= 3.14.0"])
  end
end
