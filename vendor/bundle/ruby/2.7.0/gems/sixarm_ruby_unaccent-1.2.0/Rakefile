# -*- coding: utf-8 -*-
require "rake"
require "rake/testtask"

task :default => [:test]

Rake::TestTask.new(:test) do |t|
  t.libs.push("lib", "test")
  t.pattern = "test/**/*.rb"
end

