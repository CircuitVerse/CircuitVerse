require 'simplecov'
require 'coveralls'
require 'fileutils'

module SimpleCov::Configuration
  def clean_filters
    @filters = []
  end
end

SimpleCov.configure do
  clean_filters
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'simplecov'
require 'simplecov-lcov'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
# Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  # config.before(:each) do
  #   if Dir.exist?(SimpleCov::Formatter::LcovFormatter.config.output_directory)
  #     FileUtils
  #       .remove_dir(
  #                   SimpleCov::Formatter::LcovFormatter.config.output_directory,
  #                   true
  #                  )
  #   end
  # end
end
