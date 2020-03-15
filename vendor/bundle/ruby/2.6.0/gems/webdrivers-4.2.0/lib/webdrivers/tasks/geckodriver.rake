# frozen_string_literal: true

namespace :webdrivers do
  require 'webdrivers/geckodriver'

  namespace :geckodriver do
    Webdrivers.logger.level = :info

    desc 'Print current geckodriver version'
    task :version do
      gem_ver = Webdrivers::Geckodriver.current_version
      if gem_ver
        Webdrivers.logger.info "geckodriver #{gem_ver.version}"
      else
        Webdrivers.logger.warn 'No existing geckodriver found.'
      end
    end

    desc 'Remove and download updated geckodriver if necessary'
    task :update, [:version] do |_, args|
      args.with_defaults(version: 0)
      Webdrivers::Geckodriver.required_version = args.version
      Webdrivers::Geckodriver.update
      Webdrivers.logger.info "Updated to geckodriver #{Webdrivers::Geckodriver.current_version}"
    end

    desc 'Force remove geckodriver'
    task :remove do
      unless File.exist? Webdrivers::Geckodriver.driver_path
        Webdrivers.logger.info 'No existing geckodriver to remove.'
        next # Return early
      end

      cur_version = Webdrivers::Geckodriver.current_version
      Webdrivers::Geckodriver.remove

      if File.exist? Webdrivers::Geckodriver.driver_path # Failed for some reason
        Webdrivers.logger.error 'Failed to remove geckodriver. Please try removing manually.'
      else
        Webdrivers.logger.info "Removed geckodriver #{cur_version}."
      end
    end
  end
end
