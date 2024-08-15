# frozen_string_literal: true

module Webdrivers
  #
  # @example Enable full logging
  #   Webdrivers.logger.level = :debug
  #
  # @example Log to file
  #   Webdrivers.logger.output = 'webdrivers.log'
  #
  # @example Use logger manually
  #   Webdrivers.logger.info('This is info message')
  #   Webdrivers.logger.warn('This is warning message')
  #
  class Logger < Selenium::WebDriver::Logger
    def initialize
      super('Webdrivers')
    end
  end
end
