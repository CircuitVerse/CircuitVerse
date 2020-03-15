require 'bundler/setup'
require 'rake'
require 'bundler/gem_tasks'

require 'wwtd/tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task default: "wwtd:local"
