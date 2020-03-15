# frozen_string_literal: true

module Webdrivers
  #
  # @api private
  #
  class EdgeFinder
    class << self
      def version
        version = send("#{System.platform}_version", location)
        raise VersionError, 'Failed to find Edge version.' if version.nil? || version.empty?

        Webdrivers.logger.debug "Browser version: #{version}"
        version[/\d+\.\d+\.\d+\.\d+/] # Microsoft Edge 73.0.3683.75 -> 73.0.3683.75
      end

      def location
        edge_bin = user_defined_location || send("#{System.platform}_location")
        return edge_bin unless edge_bin.nil?

        raise BrowserNotFound, 'Failed to find Edge binary.'
      end

      private

      def user_defined_location
        if Selenium::WebDriver::EdgeChrome.path
          Webdrivers.logger.debug "Selenium::WebDriver::EdgeChrome.path: #{Selenium::WebDriver::EdgeChrome.path}"
          return Selenium::WebDriver::EdgeChrome.path
        end

        return if ENV['WD_EDGE_CHROME_PATH'].nil?

        Webdrivers.logger.debug "WD_EDGE_CHROME_PATH: #{ENV['WD_EDGE_CHROME_PATH']}"
        ENV['WD_EDGE_CHROME_PATH']
      end

      def win_location
        envs = %w[LOCALAPPDATA PROGRAMFILES PROGRAMFILES(X86)]
        directories = ['\\Microsoft\\Edge Beta\\Application',
                       '\\Microsoft\\Edge Dev\\Application',
                       '\\Microsoft\\Edge SxS\\Application']
        file = 'msedge.exe'

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
        files = ['/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge',
                 '/Applications/Microsoft Edge Beta.app/Contents/MacOS/Microsoft Edge Beta',
                 '/Applications/Microsoft Edge Dev.app/Contents/MacOS/Microsoft Edge Dev',
                 '/Applications/Microsoft Edge Canary.app/Contents/MacOS/Microsoft Edge Canary']

        directories.each do |dir|
          files.each do |file|
            option = "#{dir}/#{file}"
            return option if File.exist?(option)
          end
        end
        nil
      end

      def linux_location
        raise 'Default location not yet known'
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
