# frozen_string_literal: true

require 'nokogiri'
require 'webdrivers/common'

module Webdrivers
  class Geckodriver < Common
    class << self
      #
      # Returns current geckodriver version.
      #
      # @return [Gem::Version]
      def current_version
        Webdrivers.logger.debug 'Checking current version'
        return nil unless exists?

        version = binary_version
        return nil if version.nil?

        normalize_version version.match(/geckodriver (\d+\.\d+\.\d+)/)[1]
      end

      #
      # Returns latest available geckodriver version.
      #
      # @return [Gem::Version]
      def latest_version
        @latest_version ||= with_cache(file_name) { normalize_version(Network.get_url("#{base_url}/latest")[/[^v]*$/]) }
      end

      #
      # Returns url with domain for calls to get this driver.
      #
      # @return [String]
      def base_url
        'https://github.com/mozilla/geckodriver/releases'
      end

      private

      def file_name
        System.platform == 'win' ? 'geckodriver.exe' : 'geckodriver'
      end

      def direct_url(version)
        "#{base_url}/download/v#{version}/geckodriver-v#{version}-#{platform_ext}"
      end

      def platform_ext
        case System.platform
        when 'linux'
          "linux#{System.bitsize}.tar.gz"
        when 'mac'
          'macos.tar.gz'
        when 'win'
          "win#{System.bitsize}.zip"
        end
      end
    end
  end
end

::Selenium::WebDriver::Firefox::Service.driver_path = proc { ::Webdrivers::Geckodriver.update }
