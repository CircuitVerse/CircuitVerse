# frozen_string_literal: true

require "bundler/gem_tasks"

desc 'Start development Rails app'
task :web do
  app_path = 'spec/dummy'
  port     = ENV['PORT'] || 3000

  puts "Starting application in http://localhost:#{port} ... \n"

  Dir.chdir(app_path)
  exec("rails s -p #{port}")
end
