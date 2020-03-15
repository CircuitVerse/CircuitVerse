# frozen_string_literal: true

require 'shellwords'
require 'webdrivers/common'
require 'webdrivers/chromedriver'
require 'webdrivers/edge_finder'

module Webdrivers
  class Edgedriver < Chromedriver
    class << self
      undef :chrome_version
      #
      # Returns currently installed Edge version.
      #
      # @return [Gem::Version]
      def browser_version
        normalize_version EdgeFinder.version
      end

      #
      # Returns url with domain for calls to get this driver.
      #
      # @return [String]
      def base_url
        # 'https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/'
        'https://msedgedriver.azureedge.net/'
      end

      def remove
        super
      end

      private

      def latest_point_release(version)
        # Microsoft doesn't currently provide LATEST_RELEASE_X.Y.Z - only use X
        # but require the driver version be >= the passed in version
        str = Network.get(URI.join(base_url, "LATEST_RELEASE_#{version.segments[0]}"))
        latest_release = normalize_version(str.encode('ASCII-8BIT', 'UTF-16'))
        raise VersionError unless latest_release >= version

        latest_release
      rescue NetworkError, VersionError
        msg = failed_to_find_message(version)
        Webdrivers.logger.debug msg
        raise VersionError, msg
      end

      def failed_to_find_message(version)
        msg = "Unable to find latest point release version for #{version}."
        msg = begin
          # str = Network.get(URI.join(base_url, 'LATEST_RELEASE'))
          # Microsoft doesn't yet/ever support LATEST_RELEASE - Use Canary as latest
          str = Network.get(URI.join(base_url, 'LATEST_CANARY'))
          latest_release = normalize_version(str.encode('ASCII-8BIT', 'UTF-16'))
          if version > latest_release
            "#{msg} You appear to be using a non-production version of Edge."
          else
            msg
          end
              rescue NetworkError
                "#{msg} A network issue is preventing determination of latest msedgedriver release."
        end

        "#{msg} Please set `Webdrivers::Edgedriver.required_version = <desired driver version>` "\
        "to a known edgedriver version: Can not reach #{base_url}"
      end

      def file_name
        System.platform == 'win' ? 'msedgedriver.exe' : 'msedgedriver'
      end

      def download_url
        return @download_url if @download_url

        version = if required_version == EMPTY_VERSION
                    latest_version
                  else
                    normalize_version(required_version)
                  end

        file_name = System.platform == 'win' ? 'win32' : "#{System.platform}64"
        url = "#{base_url}/#{version}/edgedriver_#{file_name}.zip"
        Webdrivers.logger.debug "msedgedriver URL: #{url}"
        @download_url = url
      end
    end
  end
end

if defined? Selenium::WebDriver::EdgeChrome
  if ::Selenium::WebDriver::Service.respond_to? :driver_path=
    ::Selenium::WebDriver::EdgeChrome::Service.driver_path = proc { ::Webdrivers::Edgedriver.update }
  else
    # v3.141.0 and lower
    module Selenium
      module WebDriver
        module EdgeChrome
          def self.driver_path
            @driver_path ||= Webdrivers::Edgedriver.update
          end
        end
      end
    end
  end
end
