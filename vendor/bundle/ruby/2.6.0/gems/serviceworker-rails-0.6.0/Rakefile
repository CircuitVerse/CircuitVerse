# frozen_string_literal: true

require "rubygems"
require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

APP_RAKEFILE = File.expand_path("test/sample/Rakefile", __dir__)
load "rails/tasks/engine.rake"

RuboCop::RakeTask.new

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: %i[test rubocop]

task :compile do
  if defined?(Webpacker)
    Dir.chdir("test/sample") do
      sh "NODE_ENV=test yarn install"
      sh "RAILS_ENV=test ./bin/rake webpacker:compile"
    end
  end
end

Rake::Task[:test].enhance [:compile] do
  if defined?(Webpacker)
    Dir.chdir("test/sample") do
      sh "RAILS_ENV=test ./bin/rake webpacker:clobber"
    end
  end
end
