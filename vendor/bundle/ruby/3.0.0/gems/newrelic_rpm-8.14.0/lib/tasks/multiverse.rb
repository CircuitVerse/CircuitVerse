# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.
# frozen_string_literal: true
#
# Rake task for running Ruby agent multiverse tests. This file may be required
# from third party gems. It is also used by the agent itself to run multiverse.
#
# Multiverse tests are grouped in (potentially multiverse) "suite" directories.
# These suites are found by default under ./test/multiverse. That location can
# be overridden with ENV['SUITES_DIRECTORY'].
#
# The first parameter to this task is a suite directory name to run.  If
# excluded, multiverse will run all suites it finds.
#
# Additional parameters are allowed to multiverse. Many parameters can be
# combined.
#
# Some examples:
#
#   # Runs ./test/multiverse/*
#   bundle exec rake test:multiverse
#
#   # Runs ./test/multiverse/my_gem
#   bundle exec rake test:multiverse[my_gem]
#
#   # With verbose logging and debugging via pry
#   bundle exec rake test:multiverse[my_gem,verbose,debug]
#
#   # Runs only first set of gems defined in my_gem's Envfile
#   bundle exec rake test:multiverse[my_gem,env=0]
#
#   # Runs tests matching the passed name (via Minitest's built-in filtering)
#   bundle exec rake test:multiverse[my_gem,name=MyGemTest]
#
#   # Runs with a specific test seed
#   bundle exec rake test:multiverse[my_gem,seed=1337]

require_relative 'helpers/removers'
include Removers

namespace :test do
  desc "Run functional test suite for New Relic"
  task :multiverse, [:suite, :param1, :param2, :param3, :param4] => ['multiverse:env'] do |_, args|
    Multiverse::Runner.run(args.suite, Multiverse::Runner.parse_args(args))
  end

  namespace :multiverse do
    task :env do
      # ENV['SUITES_DIRECTORY'] = File.expand_path('../../test/multiverse/suites', __FILE__)
      require File.expand_path('../../../test/multiverse/lib/multiverse', __FILE__)
    end

    task :clobber do
      remove_local_multiverse_databases
      remove_generated_gemfiles
      remove_generated_gemfile_lockfiles
    end

    desc "Clean cached gemfiles from Bundler.bundle_path"
    task :clean_gemfile_cache do
      glob = File.expand_path('multiverse-cache/Gemfile.*.lock', Bundler.bundle_path)
      File.delete(*Dir[glob])
    end

    desc "Test the multiverse testing framework by executing tests in test/multiverse/test. Get meta with it."
    task :self, [:suite, :mode] do |_, args|
      args.with_defaults(:suite => "", :mode => "")
      puts ("Testing the multiverse testing framework...")
      test_files = FileList['test/multiverse/test/*_test.rb']
      ruby test_files.join(" ")
    end

    task :prime, [:suite] => [:env] do |_, args|
      Multiverse::Runner.prime(args.suite, Multiverse::Runner.parse_args(args))
    end
  end
end
