# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

# == New Relic Initialization
#
# When installed as a gem, you can activate the New Relic agent one of the following ways:
#
# For Rails, add:
#    config.gem 'newrelic_rpm'
# to your initialization sequence.
#
# For merb, do
#    dependency 'newrelic_rpm'
# in the Merb config/init.rb
#
# For Sinatra, do
#    require 'newrelic_rpm'
# after requiring 'sinatra'.
#
# For other frameworks, or to manage the agent manually, invoke NewRelic::Agent#manual_start
# directly.
#

require 'new_relic/control'
if defined?(Merb) && defined?(Merb::BootLoader)
  module NewRelic
    class MerbBootLoader < Merb::BootLoader
      after Merb::BootLoader::ChooseAdapter
      def self.run
        NewRelic::Control.instance.init_plugin
      end
    end
  end
elsif defined?(Rails::VERSION)
  if Rails::VERSION::MAJOR.to_i >= 3
    module NewRelic
      class Railtie < Rails::Railtie

        initializer "newrelic_rpm.start_plugin", before: :load_config_initializers do |app|
          NewRelic::Control.instance.init_plugin(:config => app.config)
        end
      end
    end
  else
    # After version 2.0 of Rails we can access the configuration directly.
    # We need it to add dev mode routes after initialization finished.
    config = nil
    config = Rails.configuration if Rails.respond_to?(:configuration)
    NewRelic::Control.instance.init_plugin :config => config
  end
else
  NewRelic::Control.instance.init_plugin
end
