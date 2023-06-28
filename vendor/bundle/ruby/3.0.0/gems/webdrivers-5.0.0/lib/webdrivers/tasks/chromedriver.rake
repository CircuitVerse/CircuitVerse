# frozen_string_literal: true

namespace :webdrivers do
  require 'webdrivers/chromedriver'

  namespace :chromedriver do
    Webdrivers.logger.level = :info

    desc 'Print current chromedriver version'
    task :version do
      gem_ver = Webdrivers::Chromedriver.current_version
      if gem_ver
        Webdrivers.logger.info "chromedriver #{gem_ver.version}"
      else
        Webdrivers.logger.warn 'No existing chromedriver found.'
      end
    end

    desc 'Remove and download updated chromedriver if necessary'
    task :update, [:version] do |_, args|
      args.with_defaults(version: 0)
      Webdrivers::Chromedriver.required_version = args.version
      Webdrivers::Chromedriver.update
      Webdrivers.logger.info "Updated to chromedriver #{Webdrivers::Chromedriver.current_version}"
    end

    desc 'Force remove chromedriver'
    task :remove do
      unless File.exist? Webdrivers::Chromedriver.driver_path
        Webdrivers.logger.info 'No existing chromedriver to remove.'
        next # Return early
      end

      cur_version = Webdrivers::Chromedriver.current_version
      Webdrivers::Chromedriver.remove

      if File.exist? Webdrivers::Chromedriver.driver_path # Failed for some reason
        Webdrivers.logger.error 'Failed to remove chromedriver. Please try removing manually.'
      else
        Webdrivers.logger.info "Removed chromedriver #{cur_version}."
      end
    end
  end
end
