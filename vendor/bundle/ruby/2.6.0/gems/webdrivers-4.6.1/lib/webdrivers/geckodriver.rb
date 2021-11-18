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

      def download_url
        @download_url ||= if required_version == EMPTY_VERSION
                            direct_url(latest_version)
                          else
                            direct_url(required_version)
                          end
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

if ::Selenium::WebDriver::Service.respond_to? :driver_path=
  ::Selenium::WebDriver::Firefox::Service.driver_path = proc { ::Webdrivers::Geckodriver.update }
else
  # v3.141.0 and lower
  module Selenium
    module WebDriver
      module Firefox
        def self.driver_path
          @driver_path ||= Webdrivers::Geckodriver.update
        end
      end
    end
  end
end
