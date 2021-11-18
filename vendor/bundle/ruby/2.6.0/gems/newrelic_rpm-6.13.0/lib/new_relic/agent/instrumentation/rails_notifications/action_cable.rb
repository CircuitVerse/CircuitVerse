# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.
require 'new_relic/agent/instrumentation/action_cable_subscriber'
require 'new_relic/agent/prepend_supportability'

DependencyDetection.defer do
  @name = :action_cable_notifications

  depends_on do
    defined?(::Rails::VERSION::MAJOR) &&
     ::Rails::VERSION::MAJOR.to_i >= 5 &&
       defined?(::ActionCable)
  end

  depends_on do
    !NewRelic::Agent.config[:disable_action_cable_instrumentation] &&
      !NewRelic::Agent::Instrumentation::ActionCableSubscriber.subscribed?
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing notifications based Action Cable instrumentation'
  end

  executes do
    # enumerate the specific events we want so that we do not get unexpected additions in the future
    ActiveSupport::Notifications.subscribe(/(perform_action|transmit)\.action_cable/,
      NewRelic::Agent::Instrumentation::ActionCableSubscriber.new)

    ActiveSupport.on_load(:action_cable) do
      ::NewRelic::Agent::PrependSupportability.record_metrics_for(::ActionCable::Engine) if defined?(::ActionCable::Engine)
      ::NewRelic::Agent::PrependSupportability.record_metrics_for(::ActionCable::RemoteConnections) if defined?(::ActionCable::RemoteConnections)
    end
  end
end
