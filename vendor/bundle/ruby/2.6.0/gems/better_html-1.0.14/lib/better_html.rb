require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/class/attribute_accessors'

module BetterHtml
  def self.configure
    yield config if block_given?
  end

  def self.config
    @config ||= Config.new
  end

  def self.config=(new_config)
    @config = new_config
  end
end

require 'better_html/version'
require 'better_html/config'
require 'better_html/helpers'
require 'better_html/errors'
require 'better_html/html_attributes'

require 'better_html/railtie' if defined?(Rails)
