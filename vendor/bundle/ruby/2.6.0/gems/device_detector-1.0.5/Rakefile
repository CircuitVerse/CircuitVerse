# frozen_string_literal: true

require 'rake'
require 'rake/testtask'

$LOAD_PATH.unshift 'lib'
require 'device_detector'

Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.libs.push 'spec'
end

task default: :test

desc 'generate detectable names output for README'
task :detectable_names do
  require 'date'

  bot_names = DeviceDetector::Bot.new('').send(:regexes)
                                 .map { |r| r[:name] }.uniq.sort_by(&:downcase)
  bot_names.delete('$1')
  client_names = DeviceDetector::Client.new('').send(:regexes)
                                       .map { |r| r[:name] }.uniq.sort_by(&:downcase)
  client_names.delete('$1')
  device = DeviceDetector::Device.new('')
  device_paths = device.send(:filepaths)
  device_regexes = device.send(:load_regexes, device_paths)
  device_names = device_regexes.flat_map { |dn| dn[1].keys }.uniq.sort_by(&:downcase)

  today = Date.today.strftime

  puts '## Detectable clients, bots and devices'
  puts
  puts "Updated on #{today}"
  puts
  puts '### Bots'
  puts
  puts bot_names.join(', ')
  puts
  puts '### Clients'
  puts
  puts client_names.join(', ')
  puts
  puts '### Devices'
  puts
  puts device_names.join(', ')
  puts
end

PIWIK_REPO_URL = 'https://github.com/matomo-org/device-detector'
PIWIK_CHECKOUT_LOCATION = '/tmp/matomo_device_detector'

def get_latest_piwik_checkout
  if File.exist?(PIWIK_CHECKOUT_LOCATION)
    system "cd #{PIWIK_CHECKOUT_LOCATION}; git reset --hard HEAD; git pull origin master"
  else
    system "git clone --depth 1 #{PIWIK_REPO_URL} #{PIWIK_CHECKOUT_LOCATION}"
  end
end

desc 'update regex database from piwik project'
task :update_regexes do
  top = File.expand_path(__dir__)
  get_latest_piwik_checkout
  system "cp -R #{PIWIK_CHECKOUT_LOCATION}/regexes/* #{top}/regexes"
end

desc 'update fixtures from piwik project'
task :update_fixtures do
  top = File.expand_path(__dir__)
  get_latest_piwik_checkout

  fixture_mappings = [
    { target_path: "#{top}/spec/fixtures/detector", source_path: 'Tests/fixtures/*.yml' },
    { target_path: "#{top}/spec/fixtures/client", source_path: 'Tests/Parser/Client/fixtures/*.yml' },
    { target_path: "#{top}/spec/fixtures/parser", source_path: 'Tests/Parser/fixtures/*.yml' },
    { target_path: "#{top}/spec/fixtures/device", source_path: 'Tests/Parser/Devices/fixtures/*.yml' }
  ]

  fixture_mappings.each do |mapping|
    source_path = mapping.fetch(:source_path)
    target_path = mapping.fetch(:target_path)
    system "cp -R #{PIWIK_CHECKOUT_LOCATION}/#{source_path} #{target_path}"
  end
end
