require 'rake/testtask'
require 'rake/clean'

namespace :ext do
  load 'ext/mimemagic/Rakefile'
end
CLOBBER.include("lib/mimemagic/path.rb")

task :default => %w(test)

desc 'Run tests with minitest'
Rake::TestTask.new("test" => "ext:default") do |t|
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
end

desc 'Generate mime tables'
task :tables => 'lib/mimemagic/tables.rb'
file 'lib/mimemagic/tables.rb' => FileList['script/freedesktop.org.xml'] do |f|
  sh "script/generate-mime.rb #{f.prerequisites.join(' ')} > #{f.name}"
end

