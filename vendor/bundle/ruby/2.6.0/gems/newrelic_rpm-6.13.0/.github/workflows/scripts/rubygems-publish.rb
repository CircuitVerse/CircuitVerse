gem_name = ARGV[0]
raise "gem name sans version must be supplied" if gem_name.to_s == ""

api_key = ENV["GEM_HOST_API_KEY"]
raise "GEM_HOST_API_KEY must be set" if api_key.to_s == ""

version = ENV["VERSION"]
raise "VERSION environment must be set" if version.to_s == ""

gem_filename = "#{gem_name}-#{version}.gem"
raise "#{gem_filenam} is missing!" unless File.exist?(gem_filename)

otp = ENV["RUBYGEMS_OTP"]
raise "RUBYGEMS_OTP environment must be set" if otp.to_s == ""

puts "Publshing the newrelic_rpm-#{version}.gem file..."
cmd = "gem push --otp #{otp} #{gem_name}-#{version}.gem"
puts "executing: #{cmd}"

result = `#{cmd}`
if $?.to_i.zero?
  puts "#{gem_filename} successfully pushed to rubygems.org!"
else
  if result =~ /Repushing of gem versions is not allowed/
    puts "Pushing #{gem_filename} skipped because this version is already published to rubygems.org!"
    exit 0
  else
    puts "#{gem_filename} failed to push to rubygems.org!"
    puts result
    exit 1
  end
end
