# frozen_string_literal: true

require 'webdrivers'
require 'rails'

module Webdrivers
  class Railtie < Rails::Railtie
    railtie_name :webdrivers

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/*.rake").each { |f| load f }
    end
  end
end
