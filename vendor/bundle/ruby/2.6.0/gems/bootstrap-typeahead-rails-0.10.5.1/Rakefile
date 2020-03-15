#!/usr/bin/env rake

require 'json'
require File.expand_path('../lib/bootstrap-typeahead-rails/version', __FILE__)

desc "Update assets"
task :update do
  if Dir.exist?('bootstrap-typeahead-src')
    system("cd bootstrap-typeahead-src && git pull && cd ..")
  else
    system("git clone git@github.com:twitter/typeahead.js.git bootstrap-typeahead-src")
  end

  system("cp bootstrap-typeahead-src/dist/typeahead.bundle.js vendor/assets/javascripts/bootstrap-typeahead-rails/bootstrap-typeahead.js")

  system("git status")

  puts "\n"
  puts "bootstrap-typeahead version:       #{JSON.parse(File.read('./bootstrap-typeahead-src/bower.json'))['version']}"
  puts "bootstrap-typeahead-rails version: #{BootstrapTypeaheadRails::Rails::VERSION}"
end

desc "Build"
task "build" do
  system("gem build bootstrap-typeahead-rails.gemspec")
end

desc "Build and publish the gem"
task :publish => :build do
  tags = `git tag`.split
  current_version = BootstrapTypeaheadRails::Rails::VERSION
  system("git tag -a #{current_version} -m 'Release #{current_version}'") unless tags.include?(current_version)
  system("gem push bootstrap-typeahead-rails-#{current_version}.gem")
  system("git push --follow-tags")
end

task :release => :publish do
end