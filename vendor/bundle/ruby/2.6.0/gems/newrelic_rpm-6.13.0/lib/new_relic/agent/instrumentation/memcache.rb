# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

# NOTE there are multiple implementations of the MemCache client in Ruby,
# each with slightly different API's and semantics.
# See:
#     http://www.deveiate.org/code/Ruby-MemCache/ (Gem: Ruby-MemCache)
#     http://seattlerb.rubyforge.org/memcache-client/ (Gem: memcache-client)
#     https://github.com/mperham/dalli (Gem: dalli)

require 'new_relic/agent/datastores/metric_helper'
require 'new_relic/agent/instrumentation/memcache/dalli'

module NewRelic
  module Agent
    module Instrumentation
      module Memcache
        module_function

        def enabled?
          !::NewRelic::Agent.config[:disable_memcache_instrumentation]
        end

        METHODS = [:get, :get_multi, :set, :add, :incr, :decr, :delete, :replace, :append,
                   :prepend, :cas, :single_get, :multi_get, :single_cas, :multi_cas]

        def supported_methods_for(client_class, methods)
          methods.select do |method_name|
            client_class.method_defined?(method_name) || client_class.private_method_defined?(method_name)
          end
        end

        def instrument_methods(client_class, requested_methods = METHODS)
          supported_methods_for(client_class, requested_methods).each do |method_name|

            visibility = NewRelic::Helper.instance_method_visibility client_class, method_name
            method_name_without = :"#{method_name}_without_newrelic_trace"

            client_class.class_eval do
              alias_method method_name_without, method_name

              define_method method_name do |*args, &block|
                segment = NewRelic::Agent::Tracer.start_datastore_segment(
                  product: "Memcached",
                  operation: method_name
                )
                begin
                  NewRelic::Agent::Tracer.capture_segment_error segment do
                    send method_name_without, *args, &block
                  end
                ensure
                  if NewRelic::Agent.config[:capture_memcache_keys]
                    segment.notice_nosql_statement "#{method_name} #{args.first.inspect}"
                  end
                  segment.finish if segment
                end
              end

              send visibility, method_name
              send visibility, method_name_without
            end
          end
        end

      end
    end
  end
end

DependencyDetection.defer do
  named :memcache_client

  depends_on do
    NewRelic::Agent::Instrumentation::Memcache.enabled?
  end

  depends_on do
    defined?(::MemCache)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Memcached instrumentation for memcache-client gem'
    NewRelic::Agent::Instrumentation::Memcache.instrument_methods(::MemCache)
  end
end

DependencyDetection.defer do
  named :memcached

  depends_on do
    NewRelic::Agent::Instrumentation::Memcache.enabled?
  end

  depends_on do
    defined?(::Memcached)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Memcached instrumentation for memcached gem'
    ::NewRelic::Agent::Instrumentation::Memcache.instrument_methods(::Memcached)
  end
end
