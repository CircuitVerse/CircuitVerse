# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.
# frozen_string_literal: true

# NOTE: there are multiple implementations of the Memcached client in Ruby,
# each with slightly different APIs and semantics.
# See:
#     http://www.deveiate.org/code/Ruby-MemCache/ (Gem: Ruby-MemCache)
#     http://seattlerb.rubyforge.org/memcache-client/ (Gem: memcache-client)
#     https://github.com/mperham/dalli (Gem: dalli)

require_relative 'memcache/helper'
require_relative 'memcache/instrumentation'
require_relative 'memcache/dalli'
require_relative 'memcache/chain'
require_relative 'memcache/prepend'

DependencyDetection.defer do
  named :memcache_client

  depends_on { defined? MemCache }

  executes do
    if use_prepend?
      prepend_module = NewRelic::Agent::Instrumentation::Memcache::Prepend.client_prepender(MemCache)
      prepend_instrument MemCache, prepend_module, "MemcacheClient"
    else
      chain_instrument_target MemCache, NewRelic::Agent::Instrumentation::Memcache::Chain, "MemcacheClient"
    end
  end
end

DependencyDetection.defer do
  named :memcached

  depends_on { defined? Memcached }

  executes do
    if use_prepend?
      prepend_module = NewRelic::Agent::Instrumentation::Memcache::Prepend.client_prepender(Memcached)
      prepend_instrument Memcached, prepend_module, "Memcached"
    else
      chain_instrument_target Memcached, NewRelic::Agent::Instrumentation::Memcache::Chain, "Memcached"
    end
  end
end

DependencyDetection.defer do
  named :dalli
  configure_with :memcache

  depends_on { defined? Dalli::Client }

  executes do
    if use_prepend?
      prepend_module = NewRelic::Agent::Instrumentation::Memcache::Prepend
      prepend_module.dalli_prependers do |client_class, instrumenting_module|
        prepend_instrument client_class, instrumenting_module, "MemcachedDalli"
      end
    else
      chain_instrument NewRelic::Agent::Instrumentation::Memcache::Dalli
    end
  end
end

# These CAS client methods are only optionally defined if users require
# dalli/cas/client. Use a separate dependency block so it can potentially
# re-evaluate after they've done that require.
DependencyDetection.defer do
  named :dalli_cas_client
  configure_with :memcache

  depends_on { defined? Dalli::Client }
  depends_on { NewRelic::Agent::Instrumentation::Memcache::DalliCAS.should_instrument? }

  executes do
    NewRelic::Agent.logger.info('Installing Dalli CAS Client Memcache instrumentation')
    if use_prepend?
      prepend_module = NewRelic::Agent::Instrumentation::Memcache::Prepend
      prepend_module.dalli_cas_prependers do |client_class, instrumenting_module|
        prepend_instrument client_class, instrumenting_module, "MemcachedDalliCAS"
      end
    else
      chain_instrument NewRelic::Agent::Instrumentation::Memcache::DalliCAS
    end
  end
end
