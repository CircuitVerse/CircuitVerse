# frozen_string_literal: true

namespace :webdrivers do
  require 'webdrivers/edgedriver'

  namespace :edgedriver do
    Webdrivers.logger.level = :info

    desc 'Print current edgedriver version'
    task :version do
      gem_ver = Webdrivers::Edgedriver.current_version
      if gem_ver
        Webdrivers.logger.info "edgedriver #{gem_ver.version}"
      else
        Webdrivers.logger.warn 'No existing edgedriver found.'
      end
    end

    desc 'Remove and download updated edgedriver if necessary'
    task :update, [:version] do |_, args|
      args.with_defaults(version: 0)
      Webdrivers::Edgedriver.required_version = args.version
      Webdrivers::Edgedriver.update
      Webdrivers.logger.info "Updated to edgedriver #{Webdrivers::Edgedriver.current_version}"
    end

    desc 'Force remove edgedriver'
    task :remove do
      unless File.exist? Webdrivers::Edgedriver.driver_path
        Webdrivers.logger.info 'No existing edgedriver to remove.'
        next # Return early
      end

      cur_version = Webdrivers::Edgedriver.current_version
      Webdrivers::Edgedriver.remove

      if File.exist? Webdrivers::Edgedriver.driver_path # Failed for some reason
        Webdrivers.logger.error 'Failed to remove edgedriver. Please try removing manually.'
      else
        Webdrivers.logger.info "Removed edgedriver #{cur_version}."
      end
    end
  end
end
