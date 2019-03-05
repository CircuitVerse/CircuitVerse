namespace :spec do
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:all)
rescue LoadError
end
