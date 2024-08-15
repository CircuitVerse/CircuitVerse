require 'bundler/gem_tasks'

task default: ['spec']

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

# Rdoc
require 'rdoc/task'

desc 'Generate documentation for the rsolr gem.'
RDoc::Task.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'RSolr'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
