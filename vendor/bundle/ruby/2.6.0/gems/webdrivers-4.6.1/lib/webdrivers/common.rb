# frozen_string_literal: true

require 'rubygems/package'
require 'webdrivers/logger'
require 'webdrivers/network'
require 'webdrivers/system'
require 'selenium-webdriver'
require 'webdrivers/version'

module Webdrivers
  class ConnectionError < StandardError
  end

  class VersionError < StandardError
  end

  class NetworkError < StandardError
  end

  class BrowserNotFound < StandardError
  end

  DEFAULT_CACHE_TIME = 86_400 # 24 hours
  DEFAULT_INSTALL_DIR = File.expand_path('~/.webdrivers')

  class << self
    attr_accessor :proxy_addr, :proxy_port, :proxy_user, :proxy_pass
    attr_writer :install_dir, :cache_time

    #
    # Returns the amount of time (Seconds) the gem waits between two update checks.
    # @note Value from the environment variable "WD_CACHE_TIME" takes precedence over Webdrivers.cache_time. If neither
    # are set, it defaults to 86,400 Seconds (24 hours).
    #
    def cache_time
      @cache_time ||= (ENV['WD_CACHE_TIME'] || DEFAULT_CACHE_TIME)
      @cache_time.to_i
    end

    #
    # Returns the install (download) directory path for the drivers.
    #
    # @return [String]
    def install_dir
      @install_dir ||= ENV['WD_INSTALL_DIR'] || DEFAULT_INSTALL_DIR
    end

    def logger
      @logger ||= Webdrivers::Logger.new
    end

    #
    # Provides a convenient way to configure the gem.
    #
    # @example Configure proxy and cache_time
    #   Webdrivers.configure do |config|
    #     config.proxy_addr = 'myproxy_address.com'
    #     config.proxy_port = '8080'
    #     config.proxy_user = 'username'
    #     config.proxy_pass = 'password'
    #     config.cache_time = 604_800 # 7 days
    #   end
    #
    def configure
      yield self
    end

    def net_http_ssl_fix
      raise 'Webdrivers.net_http_ssl_fix is no longer available.' \
      ' Please see https://github.com/titusfortner/webdrivers#ssl_connect-errors.'
    end
  end

  class Common
    class << self
      attr_writer :required_version

      #
      # Returns the user defined required version.
      #
      # @return [Gem::Version]
      def required_version
        normalize_version(@required_version ||= nil)
      end

      #
      # Triggers an update check.
      #
      # @return [String] Path to the driver binary.
      def update
        if correct_binary?
          msg = required_version != EMPTY_VERSION ?  'The required webdriver version' : 'A working webdriver version'
          Webdrivers.logger.debug "#{msg} is already on the system"
          return driver_path
        end

        remove
        System.download(download_url, driver_path)
      end

      #
      # Deletes the existing driver binary.
      #
      def remove
        @download_url = nil
        @latest_version = nil
        System.delete "#{System.install_dir}/#{file_name.gsub('.exe', '')}.version"
        System.delete driver_path
      end

      #
      # Returns path to the driver binary.
      #
      # @return [String]
      def driver_path
        File.absolute_path File.join(System.install_dir, file_name)
      end

      private

      def download_url
        @download_url ||= if required_version == EMPTY_VERSION
                            downloads[downloads.keys.max]
                          else
                            downloads[normalize_version(required_version)]
                          end
      end

      def exists?
        System.exists? driver_path
      end

      def correct_binary?
        current_version == if required_version == EMPTY_VERSION
                             latest_version
                           else
                             normalize_version(required_version)
                           end
      rescue ConnectionError, VersionError
        driver_path if sufficient_binary?
      end

      def sufficient_binary?
        exists?
      end

      def normalize_version(version)
        Gem::Version.new(version.to_s)
      end

      def binary_version
        version = System.call(driver_path, '--version')
        Webdrivers.logger.debug "Current version of #{driver_path} is #{version}"
        version
      rescue Errno::ENOENT
        Webdrivers.logger.debug "No Such File or Directory: #{driver_path}"
        nil
      end

      # Returns cached driver version if cache is still valid and the driver binary exists.
      # Otherwise caches the given version (typically the latest available)
      # In case of Chrome, it also verifies that the driver build and browser build versions are compatible.
      # Example usage: lib/webdrivers/chromedriver.rb:34
      def with_cache(file_name, driver_build = nil, browser_build = nil)
        if System.valid_cache?(file_name) && exists? && (driver_build == browser_build)
          cached_version = System.cached_version(file_name)
          Webdrivers.logger.debug "using cached version as latest: #{cached_version}"
          normalize_version cached_version
        else
          version = yield
          System.cache_version(file_name, version)
          normalize_version version
        end
      end

      EMPTY_VERSION = Gem::Version.new('')
    end
  end
end
