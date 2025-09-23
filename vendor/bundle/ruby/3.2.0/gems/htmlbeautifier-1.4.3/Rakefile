require "rspec/core/rake_task"

desc "Run the specs."
RSpec::Core::RakeTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.verbose = false
end

task :default => [:spec]

if Gem.loaded_specs.key?('rubocop')
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  task(:default).prerequisites << task(:rubocop)
end
