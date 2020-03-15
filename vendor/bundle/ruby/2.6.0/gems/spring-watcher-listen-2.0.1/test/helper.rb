$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "bundler/setup"
require "spring/test"
require "minitest/autorun"

if defined?(Celluloid)
  require "celluloid/test"
  Celluloid.logger.level = Logger::WARN
end

Spring::Test.root = File.expand_path('..', __FILE__)
