# frozen_string_literal: true

require 'bundler/setup'
require 'rake'
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task default: 'spec'


task :update_gemfiles do
  require 'pry'
  Dir.glob('gemfiles/*.gemfile').each do |gemfile|
    puts "Updating #{gemfile}...\n\n"
    ENV['BUNDLE_GEMFILE']=gemfile
    puts `bundle install --gemfile=#{gemfile} --no-cache`
    puts `bundle update --gemfile=#{gemfile}`

    lockfile = "#{gemfile}.lock"

    if File.exist? lockfile
      parsed_lockfile = Bundler::LockfileParser.new(Bundler.read_file(lockfile))
      # Ensure lockfile has x86_64-linux
      if parsed_lockfile.platforms.map(&:to_s).none? {|p| p == 'x86_64-linux' }
        puts "Adding platform x86_64-linux to #{lockfile}\n\n"
        puts `bundle lock --add-platform x86_64-linux --gemfile=#{gemfile}`
      end

      puts ""
    else
      raise StandardError.new("Expected #{lockfile} to exist.")
    end
  end
end
