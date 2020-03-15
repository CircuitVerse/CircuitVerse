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
        'https://selenium-release.storage.googleapis.com/'
      end

      private

      def file_name
        'IEDriverServer.exe'
      end

      def downloads
        doc = Nokogiri::XML.parse(Network.get(base_url))
        items = doc.css('Key').collect(&:text)
        items.select! { |item| item.include?('IEDriverServer_Win32') }
        ds = items.each_with_object({}) do |item, hash|
          key = normalize_version item[/([^_]+)\.zip/, 1]
          hash[key] = "#{base_url}#{item}"
        end
        Webdrivers.logger.debug "Versions now located on downloads site: #{ds.keys}"
        ds
      end
    end
  end
end

if ::Selenium::WebDriver::Service.respond_to? :driver_path=
  ::Selenium::WebDriver::IE::Service.driver_path = proc { ::Webdrivers::IEdriver.update }
else
  # v3.141.0 and lower
  module Selenium
    module WebDriver
      module IE
        def self.driver_path
          @driver_path ||= Webdrivers::IEdriver.update
        end
      end
    end
  end
end
