require 'bundler/gem_tasks'

task :test do
  $LOAD_PATH.unshift('lib', 'test')
  require './test/disposable_mail_tests.rb'
end

task default: :test

namespace :disposable_mail do
  desc "outputs the current disposable domains"
  task :puts_domains do
    blacklist_path = 'data/disposable-email-domains/disposable_email_blacklist.conf'
    new_list = File.open(File.expand_path(File.join(File.dirname(__FILE__), blacklist_path))).readlines.map(&:strip).sort.to_s.gsub(/,/, ",\n")
    new_list = new_list.sub(/\]/, "\n]")
    new_list = new_list.sub(/\[/, "[\n")

    temp_dir = File.join(File.dirname(__FILE__), 'tmp')
    Dir.mkdir(temp_dir) unless Dir.exist?(temp_dir)

    File.open(File.expand_path(File.join(File.dirname(__FILE__), 'tmp/new_list.txt')), 'w') do |f|
      f.write(new_list)
    end
  end
end
