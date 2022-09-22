# frozen_string_literal: true

namespace :webdrivers do
  require 'webdrivers/iedriver'

  namespace :iedriver do
    Webdrivers.logger.level = :info

    desc 'Print current IEDriverServer version'
    task :version do
      gem_ver = Webdrivers::IEdriver.current_version
      if gem_ver
        Webdrivers.logger.info "IEDriverServer #{gem_ver.version}"
      else
        Webdrivers.logger.warn 'No existing IEDriverServer found.'
      end
    end

    desc 'Remove and download updated IEDriverServer if necessary'
    task :update, [:version] do |_, args|
      args.with_defaults(version: 0)
      Webdrivers::IEdriver.required_version = args.version
      Webdrivers::IEdriver.update
      Webdrivers.logger.info "Updated to IEDriverServer #{Webdrivers::IEdriver.current_version}"
    end

    desc 'Force remove IEDriverServer'
    task :remove do
      unless File.exist? Webdrivers::IEdriver.driver_path
        Webdrivers.logger.info 'No existing IEDriverServer to remove.'
        next # Return early
      end

      cur_version = Webdrivers::IEdriver.current_version
      Webdrivers::IEdriver.remove

      if File.exist? Webdrivers::IEdriver.driver_path # Failed for some reason
        Webdrivers.logger.error 'Failed to remove IEDriverServer. Please try removing manually.'
      else
        Webdrivers.logger.info "Removed IEDriverServer #{cur_version}."
      end
    end
  end
end
