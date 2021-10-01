require 'rubygems'
require 'rake/testtask'
require 'yard'
require "#{File.dirname(__FILE__)}/lib/tasks/all.rb"

YARD::Rake::YardocTask.new

task :default => :test
task :test => ['test:newrelic']

namespace :test do
  desc "Run all tests"
  task :all => %w{newrelic multiverse}

  begin
    require 'test_bisect'
    TestBisect::BisectTask.new do |t|
      t.test_task_name = 'test:newrelic'
    end
  rescue LoadError
  end

  agent_home = File.expand_path(File.dirname(__FILE__))

  desc "Run agent performance tests"
  task :performance, [:suite, :name] => [] do |t, args|
    require File.expand_path(File.join(File.dirname(__FILE__), 'test', 'performance', 'lib', 'performance'))
    options = {}
    options[:suite] = args[:suite] if args[:suite]
    options[:name]  = args[:name]  if args[:name]
    Performance::Runner.new(options).run_and_report
  end

  desc "Run agent within existing mini environments"
  task :env, [:env1, :env2, :env3, :env4, :env5, :env6] => [] do |t, args|
    require File.expand_path(File.join(File.dirname(__FILE__), 'test', 'environments', 'lib', 'environments', 'runner'))
    Environments::Runner.new(args.map{|_,v| v}).run_and_report
  end

  Rake::TestTask.new(:intentional_fail) do |t|
    t.libs << "#{agent_home}/test"
    t.libs << "#{agent_home}/lib"
    t.pattern = "#{agent_home}/test/intentional_fail.rb"
    t.verbose = true
  end

  Rake::TestTask.new(:nullverse) do |t|
    t.pattern = "#{agent_home}/test/nullverse/*_test.rb"
    t.verbose = true
  end

  # Note unit testing task is defined in lib/tasks/tests.rake to facilitate
  # running them in a rails application environment.

end

desc 'Record build number and stage'
task :record_build, [ :build_number, :stage ] do |t, args|
  build_string = args.build_number
  build_string << ".#{args.stage}" unless args.stage.nil? || args.stage.empty?

  gitsha = File.exists?(".git") ? `git rev-parse HEAD` : "Unknown"
  gitsha.chomp!

  File.open("lib/new_relic/build.rb", "w") do |f|
    f.write("# GITSHA: #{gitsha}\n")
    f.write("module NewRelic; module VERSION; BUILD='#{build_string}'; end; end\n")
  end
end

desc 'Update CA bundle'
task :update_ca_bundle do |t|
  ca_bundle_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'SSL_CA_cert_bundle'))
  if !File.exist?(ca_bundle_path)
    puts "Could not find SSL_CA_cert_bundle project at #{ca_bundle_path}. Please clone it."
    exit
  end
  if !File.exist?(File.join(ca_bundle_path, '.git'))
    puts "#{ca_bundle_path} does not appear to be a git repository."
    exit
  end

  puts "Updating bundle at #{ca_bundle_path} with git..."
  result = system("cd #{ca_bundle_path} && git fetch origin && git reset --hard origin/master")
  if result != true
    puts "Failed to update git repo at #{ca_bundle_path}."
    exit
  end

  bundle_last_update = `cd #{ca_bundle_path} && git show -s --format=%ci HEAD`
  puts "Source CA bundle last updated #{bundle_last_update}"

  bundle_path = "cert/cacert.pem"
  cert_paths = []
  Dir.glob("#{ca_bundle_path}/*.pem").each { |p| cert_paths << p }
  cert_paths.sort!

  puts "Writing #{cert_paths.size} certs to bundle at #{bundle_path}..."

  File.open(bundle_path, "w") do |f|
    cert_paths.each do |cert_path|
      cert_name = File.basename(cert_path, '.pem')
      puts "Adding #{cert_name}"
      f.write("#{cert_name}\n")
      f.write(File.read(cert_path))
      f.write("\n\n")
    end
  end
  puts "Done, please commit your changes to #{bundle_path}"
end

namespace :cross_agent_tests do
  cross_agent_tests_upstream_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'cross_agent_tests'))
  cross_agent_tests_local_path    = File.expand_path(File.join(File.dirname(__FILE__), 'test', 'fixtures', 'cross_agent_tests'))

  # Note: before you pull, make sure your local repo is on the correct, synced branch!
  desc 'Pull latest changes from cross_agent_tests repo'
  task :pull do
    puts "Updating embedded cross_agent_tests from #{cross_agent_tests_upstream_path}..."
    cmd = "rsync -avu --exclude .git #{cross_agent_tests_upstream_path}/ #{cross_agent_tests_local_path}/"
    puts cmd
    system(cmd)
  end

  desc 'Copy changes from embedded cross_agent_tests to official repo working copy'
  task :push do
    puts "Copying changes from embedded cross_agent_tests to #{cross_agent_tests_upstream_path}..."
    cmd = "rsync -avu #{cross_agent_tests_local_path}/ #{cross_agent_tests_upstream_path}/"
    puts cmd
    system(cmd)
  end
end

task :console do
  require 'pry'
  require 'newrelic_rpm'
  ARGV.clear
  Pry.start
end

