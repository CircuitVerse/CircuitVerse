# -*- ruby -*-

require "rubygems"
require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'
require 'rake/extensiontask'

Rake::ExtensionTask.new("html_tokenizer_ext")

task :default => :test

task :test => ['test:unit']

namespace :test do
  Rake::TestTask.new(:unit => :compile) do |t|
    t.libs << 'lib' << 'test'
    t.test_files = FileList['test/unit/**/*_test.rb']
  end
end
