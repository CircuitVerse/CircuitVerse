# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

desc 'Run RuboCop'
RuboCop::RakeTask.new(:rubocop)

desc 'Run Tests'
RSpec::Core::RakeTask.new(:spec)

task default: %i[rubocop spec]
