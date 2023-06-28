require './test/multiverse/lib/multiverse/bundler_patch'

test_folders = Dir.glob("test/new_relic/*").select { |f| File.directory?(f) }
test_folders += Dir.glob("test/new_relic/**/*").select { |f| File.directory?(f) }

rake_lib_path = Bundler.with_unbundled_env { `bundle exec gem which rake`.chomp.gsub("lib/rake.rb", "lib") }
ruby_options = %(-w -I"#{rake_lib_path}" "#{rake_lib_path}/rake/rake_test_loader.rb")

guard_options = {
  spring: "bundle exec ruby #{ruby_options} ",
  test_folders: ['test/new_relic'] + test_folders,
  all_after_pass: false,
  all_on_start: false
}

guard :minitest, guard_options do
  watch(%r{^lib/(.+)\.rb$}) { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^test/.+_test\.rb$})
  watch(%r{^test/rum/.*}) { "test/new_relic/rack/browser_monitoring_test.rb" }
  watch(%r{^test/fixtures/cross_agent_tests/distributed_tracing/(.+).json}) { |m| "test/new_relic/agent/distributed_tracing/#{m[1]}_cross_agent_test.rb" }
  watch('test/test_helper.rb') { "test/new_relic" }
  watch('test/agent_helper.rb') { "test/new_relic" }
  watch('lib/new_relic/agent/configuration/default_source.rb') { "test/new_relic/agent/configuration/orphan_configuration_test.rb" }
  watch(%r{^lib/new_relic/agent/transaction/(.+).rb}) { |m| "test/new_relic/agent/distributed_tracing/#{m[1]}_cross_agent_test.rb" }
end
