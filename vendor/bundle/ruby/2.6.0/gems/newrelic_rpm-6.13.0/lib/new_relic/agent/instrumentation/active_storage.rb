# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/instrumentation/active_storage_subscriber'

DependencyDetection.defer do
  named :active_storage

  depends_on do
    defined?(::ActiveStorage) &&
      !NewRelic::Agent::Instrumentation::ActiveStorageSubscriber.subscribed?
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing ActiveStorage 5 instrumentation'
  end

  executes do
    ActiveSupport::Notifications.subscribe(/\.active_storage$/,
      NewRelic::Agent::Instrumentation::ActiveStorageSubscriber.new)
  end
end
