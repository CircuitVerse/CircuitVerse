# -*- encoding: utf-8 -*-
# stub: newrelic_rpm 8.8.0 ruby lib

Gem::Specification.new do |s|
  s.name = "newrelic_rpm".freeze
  s.version = "8.8.0"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/newrelic/newrelic-ruby-agent/issues", "changelog_uri" => "https://github.com/newrelic/newrelic-ruby-agent/blob/main/CHANGELOG.md", "documentation_uri" => "https://docs.newrelic.com/docs/agents/ruby-agent", "homepage_uri" => "https://newrelic.com/ruby", "source_code_uri" => "https://github.com/newrelic/newrelic-ruby-agent" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tanna McClure".freeze, "Kayla Reopelle".freeze, "James Bunch".freeze, "Hannah Ramadan".freeze]
  s.date = "2022-06-02"
  s.description = "New Relic is a performance management system, developed by New Relic,\nInc (http://www.newrelic.com).  New Relic provides you with deep\ninformation about the performance of your web application as it runs\nin production. The New Relic Ruby agent is dual-purposed as a either a\nGem or plugin, hosted on\nhttps://github.com/newrelic/newrelic-ruby-agent/\n".freeze
  s.email = "support@newrelic.com".freeze
  s.executables = ["mongrel_rpm".freeze, "newrelic_cmd".freeze, "newrelic".freeze, "nrdebug".freeze]
  s.extra_rdoc_files = ["CHANGELOG.md".freeze, "LICENSE".freeze, "README.md".freeze, "CONTRIBUTING.md".freeze, "newrelic.yml".freeze]
  s.files = ["CHANGELOG.md".freeze, "CONTRIBUTING.md".freeze, "LICENSE".freeze, "README.md".freeze, "bin/mongrel_rpm".freeze, "bin/newrelic".freeze, "bin/newrelic_cmd".freeze, "bin/nrdebug".freeze, "newrelic.yml".freeze]
  s.homepage = "https://github.com/newrelic/rpm".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.0".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "New Relic Ruby Agent".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<rake>.freeze, ["= 12.3.3"])
    s.add_development_dependency(%q<rb-inotify>.freeze, ["= 0.9.10"])
    s.add_development_dependency(%q<listen>.freeze, ["= 3.0.8"])
    s.add_development_dependency(%q<minitest>.freeze, ["= 4.7.5"])
    s.add_development_dependency(%q<minitest-stub-const>.freeze, ["= 0.6"])
    s.add_development_dependency(%q<mocha>.freeze, ["~> 1.9.0"])
    s.add_development_dependency(%q<yard>.freeze, [">= 0"])
    s.add_development_dependency(%q<pry-nav>.freeze, ["~> 0.3.0"])
    s.add_development_dependency(%q<pry-stack_explorer>.freeze, ["~> 0.4.9"])
    s.add_development_dependency(%q<guard>.freeze, ["~> 2.16.0"])
    s.add_development_dependency(%q<guard-minitest>.freeze, ["~> 2.4.0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_development_dependency(%q<rubocop-performance>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rake>.freeze, ["= 12.3.3"])
    s.add_dependency(%q<rb-inotify>.freeze, ["= 0.9.10"])
    s.add_dependency(%q<listen>.freeze, ["= 3.0.8"])
    s.add_dependency(%q<minitest>.freeze, ["= 4.7.5"])
    s.add_dependency(%q<minitest-stub-const>.freeze, ["= 0.6"])
    s.add_dependency(%q<mocha>.freeze, ["~> 1.9.0"])
    s.add_dependency(%q<yard>.freeze, [">= 0"])
    s.add_dependency(%q<pry-nav>.freeze, ["~> 0.3.0"])
    s.add_dependency(%q<pry-stack_explorer>.freeze, ["~> 0.4.9"])
    s.add_dependency(%q<guard>.freeze, ["~> 2.16.0"])
    s.add_dependency(%q<guard-minitest>.freeze, ["~> 2.4.0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop-performance>.freeze, [">= 0"])
  end
end
