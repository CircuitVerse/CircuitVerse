require 'gem_hadar/simplecov'
GemHadar::SimpleCov.start
begin
  require 'debug'
rescue LoadError
end
require 'test/unit'
require 'tins'
