# frozen_string_literal: true

require 'nokogiri'
require 'rubygems/version'
require 'webdrivers/common'

module Webdrivers
  class IEdriver < Common
    class << self
      #
      # Returns current IEDriverServer.exe version.
      #
      # @return [Gem::Version]
      def current_version
        Webdrivers.logger.debug 'Checking current version'
        return nil unless exists?

        version = binary_version
        return nil if version.nil?

        normalize_version version.match(/IEDriverServer.exe (\d\.\d+\.\d+)/)[1]
      end

      #
      # Returns latest available IEDriverServer.exe version.
      #
      # @return [Gem::Version]
      def latest_version
        @latest_version ||= with_cache(file_name) { downloads.keys.max }
      end

      #
      # Returns url with domain for calls to get this driver.
      #
      # @return [String]
      def base_url
        'https://api.github.com/repos/seleniumhq/selenium/releases'
      end

      private

      def file_name
        'IEDriverServer.exe'
      end

      def direct_url(version)
        downloads[version]
      end

      def downloads
        ds = download_manifest.each_with_object({}) do |item, hash|
          version = normalize_version item['name'][/\.?([^_]+)\.zip/, 1]
          hash[version] = item['browser_download_url']
        end
        Webdrivers.logger.debug "Versions now located on downloads site: #{ds.keys}"
        ds
      end

      def download_manifest
        json = Network.get(base_url)
        all_assets = JSON.parse(json).map { |release| release['assets'] }.flatten
        all_assets.select { |asset| asset['name'].include?('IEDriverServer_Win32') }
      end
    end
  end
end

::Selenium::WebDriver::IE::Service.driver_path = proc { ::Webdrivers::IEdriver.update }
