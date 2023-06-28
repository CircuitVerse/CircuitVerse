#-*- coding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'new_relic/version'
require 'new_relic/latest_changes'

Gem::Specification.new do |s|
  s.name = "newrelic_rpm"
  s.version = NewRelic::VERSION::STRING
  s.required_ruby_version = '>= 2.2.0'
  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tanna McClure", "Kayla Reopelle", "James Bunch", "Hannah Ramadan"]
  s.licenses = ['Apache-2.0']
  s.description = <<-EOS
New Relic is a performance management system, developed by New Relic,
Inc (http://www.newrelic.com).  New Relic provides you with deep
information about the performance of your web application as it runs
in production. The New Relic Ruby agent is dual-purposed as a either a
Gem or plugin, hosted on
https://github.com/newrelic/newrelic-ruby-agent/
  EOS
  s.email = "support@newrelic.com"
  s.executables = ["mongrel_rpm", "newrelic_cmd", "newrelic", "nrdebug"]
  s.extra_rdoc_files = [
    "CHANGELOG.md",
    "LICENSE",
    "README.md",
    "CONTRIBUTING.md",
    "newrelic.yml"
  ]

  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/newrelic/newrelic-ruby-agent/issues',
    'changelog_uri' => 'https://github.com/newrelic/newrelic-ruby-agent/blob/main/CHANGELOG.md',
    'documentation_uri' => 'https://docs.newrelic.com/docs/agents/ruby-agent',
    'source_code_uri' => 'https://github.com/newrelic/newrelic-ruby-agent',
    "homepage_uri" => "https://newrelic.com/ruby"
  }

  file_list = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|infinite_tracing|\.github)/(?!agent_helper.rb)}) }
  build_file_path = 'lib/new_relic/build.rb'
  file_list << build_file_path if File.exist?(build_file_path)
  s.files = file_list

  s.homepage = "https://github.com/newrelic/rpm"
  s.require_paths = ["lib"]
  s.rubygems_version = Gem::VERSION
  s.summary = "New Relic Ruby Agent"
  s.add_development_dependency 'rake', '12.3.3'
  s.add_development_dependency 'rb-inotify', '0.9.10' # locked to support < Ruby 2.3 (and listen 3.0.8)
  s.add_development_dependency 'listen', '3.0.8' # locked to support < Ruby 2.3
  s.add_development_dependency 'minitest', '4.7.5'
  s.add_development_dependency 'minitest-stub-const', '0.6'
  s.add_development_dependency 'mocha', '~> 1.9.0'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'pry-nav', '~> 0.3.0'
  s.add_development_dependency 'pry-stack_explorer', '~> 0.4.9'
  s.add_development_dependency 'guard', '~> 2.16.0'
  s.add_development_dependency 'guard-minitest', '~> 2.4.0'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-performance'
end
