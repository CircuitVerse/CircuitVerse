# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  module Agent
    module Instrumentation
      module Memcache
        module Dalli
          extend self

          MEMCACHED = "Memcached".freeze
          METHODS = [:get, :set, :add, :incr, :decr, :delete, :replace, :append, :prepend, :cas]
          SEND_MULTIGET_METRIC_NAME = "get_multi_request".freeze
          DATASTORE_INSTANCES_SUPPORTED_VERSION = Gem::Version.new '2.6.4'
          SLASH = '/'.freeze
          UNKNOWN = 'unknown'.freeze
          LOCALHOST = 'localhost'.freeze

          def supports_datastore_instances?
            DATASTORE_INSTANCES_SUPPORTED_VERSION <= Gem::Version.new(::Dalli::VERSION)
          end

          def instrument_methods
            if supports_datastore_instances?
              ::NewRelic::Agent::Instrumentation::Memcache.instrument_methods(::Dalli::Client, METHODS)
              instrument_multi_method :get_multi
              instrument_send_multiget
              instrument_server_for_key
            else
              ::NewRelic::Agent::Instrumentation::Memcache.instrument_methods(::Dalli::Client,
                ::NewRelic::Agent::Instrumentation::Memcache::METHODS)
            end
          end

          def instrument_server_for_key
            ::Dalli::Ring.class_eval do
              alias_method :server_for_key_without_newrelic_trace, :server_for_key

              def server_for_key key
                server = server_for_key_without_newrelic_trace key
                begin
                  if txn = ::NewRelic::Agent::Tracer.current_transaction
                    segment = txn.current_segment
                    if ::NewRelic::Agent::Transaction::DatastoreSegment === segment
                      ::NewRelic::Agent::Instrumentation::Memcache::Dalli.assign_instance_to(segment, server)
                    end
                  end
                rescue => e
                  ::NewRelic::Agent.logger.warn "Unable to set instance info on datastore segment: #{e.message}"
                end
                server
              end
            end
          end

          def instrument_send_multiget
            ::Dalli::Server.class_eval do
              alias_method :send_multiget_without_newrelic_trace, :send_multiget

              def send_multiget(keys)
                segment = ::NewRelic::Agent::Tracer.start_datastore_segment(
                  product: MEMCACHED,
                  operation: SEND_MULTIGET_METRIC_NAME
                )
                ::NewRelic::Agent::Instrumentation::Memcache::Dalli.assign_instance_to(segment, self)

                begin
                  NewRelic::Agent::Tracer.capture_segment_error segment do                  
                    send_multiget_without_newrelic_trace(keys)
                  end
                ensure
                  if ::NewRelic::Agent.config[:capture_memcache_keys]
                    segment.notice_nosql_statement "#{SEND_MULTIGET_METRIC_NAME} #{keys.inspect}"
                  end
                  segment.finish if segment
                end
              end
            end
          end

          def instrument_multi_method method_name
            visibility = NewRelic::Helper.instance_method_visibility ::Dalli::Client, method_name
            method_name_without = :"#{method_name}_without_newrelic_trace"

            ::Dalli::Client.class_eval do
              alias_method method_name_without, method_name

              define_method method_name do |*args, &block|
                segment = NewRelic::Agent::Tracer.start_segment name: "Ruby/Memcached/Dalli/#{method_name}"
                begin
                  NewRelic::Agent::Tracer.capture_segment_error segment do                  
                    __send__ method_name_without, *args, &block
                  end
                ensure
                  segment.finish if segment
                end
              end

              __send__ visibility, method_name
              __send__ visibility, method_name_without
            end
          end

          def assign_instance_to segment, server
            host = port_path_or_id = nil
            if server.hostname.start_with? SLASH
              host = LOCALHOST
              port_path_or_id = server.hostname
            else
              host = server.hostname
              port_path_or_id = server.port
            end
            segment.set_instance_info host, port_path_or_id
          rescue => e
            ::NewRelic::Agent.logger.debug "Failed to retrieve memcached instance info: #{e.message}"
            segment.set_instance_info UNKNOWN, UNKNOWN
          end

        end
      end
    end
  end
end

DependencyDetection.defer do
  named :dalli

  depends_on do
    NewRelic::Agent::Instrumentation::Memcache.enabled?
  end

  depends_on do
    defined?(::Dalli::Client)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Memcache instrumentation for dalli gem'
    ::NewRelic::Agent::Instrumentation::Memcache::Dalli.instrument_methods
  end
end

DependencyDetection.defer do
  named :dalli_cas_client

  depends_on do
    NewRelic::Agent::Instrumentation::Memcache.enabled?
  end

  depends_on do
    # These CAS client methods are only optionally defined if users require
    # dalli/cas/client. Use a separate dependency block so it can potentially
    # re-evaluate after they've done that require.
    defined?(::Dalli::Client) &&
      ::NewRelic::Agent::Instrumentation::Memcache.supported_methods_for(::Dalli::Client,
                                                                         CAS_CLIENT_METHODS).any?
  end

  CAS_CLIENT_METHODS = [:get_cas, :set_cas, :replace_cas, :delete_cas]

  executes do
    ::NewRelic::Agent.logger.info 'Installing Dalli CAS Client Memcache instrumentation'
    ::NewRelic::Agent::Instrumentation::Memcache.instrument_methods(::Dalli::Client, CAS_CLIENT_METHODS)
    ::NewRelic::Agent::Instrumentation::Memcache::Dalli.instrument_multi_method(:get_multi_cas)
  end
end
