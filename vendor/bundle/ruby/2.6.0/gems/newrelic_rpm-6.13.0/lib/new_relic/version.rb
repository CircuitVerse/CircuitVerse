#!/usr/bin/ruby
# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.


module NewRelic
  module VERSION #:nodoc:
    def self.build_version_string(*parts)
      parts.compact.join('.')
    end

    MAJOR = 6
    MINOR = 13
    TINY  = 0

    begin
      require File.join(File.dirname(__FILE__), 'build')
    rescue LoadError
      BUILD = nil
    end

    STRING = build_version_string(MAJOR, MINOR, TINY, BUILD)
  end
end
