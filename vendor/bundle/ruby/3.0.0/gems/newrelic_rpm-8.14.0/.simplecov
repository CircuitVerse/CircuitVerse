# frozen_string_literal: true
require 'securerandom'

if ENV['CI']
  random = SecureRandom.uuid
  SimpleCov.command_name(random)
  SimpleCov.coverage_dir("coverage_#{random}")
end

SimpleCov.start do
  enable_coverage(:branch)
  SimpleCov.root(File.join(File.dirname(__FILE__), '/lib'))
  track_files("**/*.rb")
  formatter(SimpleCov::Formatter::SimpleFormatter) if ENV['CI']
end
