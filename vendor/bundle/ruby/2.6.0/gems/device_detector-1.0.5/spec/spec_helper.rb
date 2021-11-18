require 'minitest/autorun'
require 'minitest/spec'

$:.unshift(File.expand_path('../../lib', __FILE__))
require 'device_detector'
begin
  require "byebug"
rescue LoadError
end unless RUBY_VERSION < "2.0.0" || RUBY_ENGINE != "ruby"
