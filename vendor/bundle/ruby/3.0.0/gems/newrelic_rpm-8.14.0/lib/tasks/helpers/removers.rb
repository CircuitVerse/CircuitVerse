# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.
# frozen_string_literal: true

module Removers
  def remove_local_multiverse_databases
    list_databases_command = %(echo "show databases" | mysql -u root)
    databases = `#{list_databases_command}`.chomp!.split("\n").select { |s| s.include?('multiverse') }
    databases.each do |database|
      puts "Dropping #{database}"
      `echo "drop database #{database}" | mysql -u root`
    end
  rescue => error
    puts "ERROR: Cannot get MySQL databases..."
    puts error.message
  end

  def remove_generated_gemfiles
    file_path = File.expand_path("test/multiverse/suites")
    Dir.glob(File.join(file_path, "**", "Gemfile*")).each do |fn|
      puts "Removing #{fn.gsub(file_path, '.../suites')}"
      FileUtils.rm(fn)
    end
  end

  def remove_generated_gemfile_lockfiles
    file_path = File.expand_path("test/environments")
    Dir.glob(File.join(file_path, "**", "Gemfile.lock")).each do |fn|
      puts "Removing #{fn.gsub(file_path, '.../environments')}"
      FileUtils.rm(fn)
    end
  end
end
