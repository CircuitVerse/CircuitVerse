require "active_support"
require "minitest/autorun"
require 'better_html'
require 'better_html/parser'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.fixtures :all
end

require 'mocha/mini_test'

class ActiveSupport::TestCase
  private

  def buffer(string)
    buffer = ::Parser::Source::Buffer.new('(test)')
    buffer.source = string
    buffer
  end
end
