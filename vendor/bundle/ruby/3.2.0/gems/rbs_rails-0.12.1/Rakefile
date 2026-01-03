require "bundler/gem_tasks"
require 'rake/testtask'

task :default => [:rbs_validate, :steep, :test]

desc 'run Steep'
task :steep do
  sh 'steep', 'check'
end

task :rbs_validate do
  repo = ENV['RBS_REPO_DIR']&.then do |env|
    "--repo=#{env}"
  end
  sh "rbs #{repo} validate --silent"
end

Rake::TestTask.new do |test|
  test.libs << 'test'
  test.test_files = Dir['test/**/*_test.rb']
  test.verbose = true
end
