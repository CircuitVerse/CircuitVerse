require 'rubygems'
require 'rake'
require File.expand_path('../lib/remotipart/rails/version', __FILE__)

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "remotipart"
    gem.summary = %Q{Remotipart is a Ruby on Rails gem enabling remote multipart forms (AJAX style file uploads) with jquery-rails.}
    gem.description = %Q{Remotipart is a Ruby on Rails gem enabling remote multipart forms (AJAX style file uploads) with jquery-rails.
    This gem augments the native Rails 3 jQuery-UJS remote form function enabling asynchronous file uploads with little to no modification to your application.
    }
    gem.email = %w{greg@formasfunction.com steve@alfajango.com}
    gem.homepage = "http://opensource.alfajango.com/remotipart/"
    gem.authors = ["Greg Leppert", "Steve Schwartz"]
    gem.version = Remotipart::Rails::VERSION
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::RubygemsDotOrgTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

require 'rdoc/task'
require File.expand_path('../lib/remotipart/rails/version', __FILE__)
Rake::RDocTask.new do |rdoc|
  version = Remotipart::Rails::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "remotipart #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task default: :spec
