namespace :newrelic do
  desc "Install a default config/newrelic.yml file"
  task :install do
    load File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "install.rb"))
  end

  desc "Gratefulness is always appreciated"
  task :thanks do
    puts "The Ruby agent team is grateful to Jim Weirich for his kindness and his code. He will be missed."
  end
end
