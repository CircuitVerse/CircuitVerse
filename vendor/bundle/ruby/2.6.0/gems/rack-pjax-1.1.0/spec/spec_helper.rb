require "rubygems"
require "bundler"
Bundler.setup

$:.unshift File.expand_path("../../lib", __FILE__)
require "rack-pjax"
require 'rack/test'

Bundler.require(:test)

# helpers ripped from wycat's Rack::Offline
# (https://github.com/wycats/rack-offline/blob/master/spec/spec_helper.rb)
module Rack::Test::Methods
  def self.included(klass)
    class << klass
      attr_accessor :app
    end
  end

  def body
    last_response.body
  end

  def status
    last_response.status
  end

  def headers
    last_response.headers
  end

  def app
    self.class.app
  end
end
