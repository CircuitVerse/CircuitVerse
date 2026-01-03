# frozen_string_literal: true

$LOAD_PATH << 'lib'

require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

desc 'Run RuboCop'
RuboCop::RakeTask.new(:rubocop)

desc 'Run Tests'
RSpec::Core::RakeTask.new(:spec)

task default: %i[rubocop spec]
