# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/datastores'
require 'new_relic/agent/datastores/redis'

require_relative 'redis/instrumentation'
require_relative 'redis/chain'
require_relative 'redis/prepend'

DependencyDetection.defer do
  # Why not :redis? newrelic-redis used that name, so avoid conflicting
  named :redis_instrumentation
  configure_with :redis

  depends_on do
    defined?(::Redis) && defined?(::Redis::VERSION)
  end

  conflicts_with_prepend do
    defined?(::PrometheusExporter)
  end

  depends_on do
    NewRelic::Agent::Datastores::Redis.is_supported_version? &&
      NewRelic::Agent::Datastores::Redis.safe_from_third_party_gem?
  end

  executes do
    NewRelic::Agent.logger.info 'Installing Redis Instrumentation'
    if use_prepend?
      prepend_instrument ::Redis::Client, NewRelic::Agent::Instrumentation::Redis::Prepend
    else
      chain_instrument NewRelic::Agent::Instrumentation::Redis::Chain
    end
  end
end
