# frozen_string_literal: true

module Webdrivers
  #
  # @api private
  #
  class ChromeFinder
    class << self
      def version
        version = send("#{System.platform}_version", location)
        raise VersionError, 'Failed to find Chrome version.' if version.nil? || version.empty?

        Webdrivers.logger.debug "Browser version: #{version}"
        version[/\d+\.\d+\.\d+\.\d+/] # Google Chrome 73.0.3683.75 -> 73.0.3683.75
      end

      def location
        chrome_bin = user_defined_location || send("#{System.platform}_location")
        return chrome_bin unless chrome_bin.nil?

        raise BrowserNotFound, 'Failed to find Chrome binary.'
      end

      private

      def user_defined_location
        if Selenium::WebDriver::Chrome.path
          Webdrivers.logger.debug "Selenium::WebDriver::Chrome.path: #{Selenium::WebDriver::Chrome.path}"
          return Selenium::WebDriver::Chrome.path
        end

        return if ENV['WD_CHROME_PATH'].nil?

        Webdrivers.logger.debug "WD_CHROME_PATH: #{ENV['WD_CHROME_PATH']}"
        ENV['WD_CHROME_PATH']
      end

      def win_location
        envs = %w[LOCALAPPDATA PROGRAMFILES PROGRAMFILES(X86)]
        directories = ['\\Google\\Chrome\\Application', '\\Chromium\\Application']
        file = 'chrome.exe'

        directories.each do |dir|
          envs.each do |root|
            option = "#{ENV[root]}\\#{dir}\\#{file}"
            return option if File.exist?(option)
          end
        end

        nil
      end

      def mac_location
        directories = ['', File.expand_path('~')]
        files = ['/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
                 '/Applications/Chromium.app/Contents/MacOS/Chromium']

        directories.each do |dir|
          files.each do |file|
            option = "#{dir}/#{file}"
            return option if File.exist?(option)
          end
        end

        nil
      end

      def linux_location
        directories = %w[/usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /snap/bin /opt/google/chrome]
        files = %w[google-chrome chrome chromium chromium-browser]

        directories.each do |dir|
          files.each do |file|
            option = "#{dir}/#{file}"
            return option if File.exist?(option)
          end
        end

        nil
      end

      def win_version(location)
        System.call("powershell (Get-ItemProperty '#{location}').VersionInfo.ProductVersion")&.strip
      end

      def linux_version(location)
        System.call(location, '--product-version')&.strip
      end

      def mac_version(location)
        System.call(location, '--version')&.strip
      end
    end
  end
end
