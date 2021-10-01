# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/instrumentation/sinatra'

DependencyDetection.defer do
  @name = :padrino

  depends_on do
    !NewRelic::Agent.config[:disable_sinatra] &&
      defined?(::Padrino) && defined?(::Padrino::Routing::InstanceMethods)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Padrino instrumentation'

    # Our Padrino instrumentation relies heavily on the fact that Padrino is
    # built on Sinatra. Although it wires up a lot of its own routing logic,
    # we only need to patch into Padrino's dispatch to get things started.
    #
    # Parts of the Sinatra instrumentation (such as the TransactionNamer) are
    # aware of Padrino as a potential target in areas where both Sinatra and
    # Padrino run through the same code.
    module ::Padrino::Routing::InstanceMethods
      include NewRelic::Agent::Instrumentation::Sinatra

      alias dispatch_without_newrelic dispatch!
      alias dispatch! dispatch_with_newrelic

      # Padrino 0.13 mustermann routing
      if private_method_defined?(:invoke_route)
        include NewRelic::Agent::Instrumentation::Padrino

        alias invoke_route_without_newrelic invoke_route
        alias invoke_route invoke_route_with_newrelic
      end
    end
  end
end

module NewRelic
  module Agent
    module Instrumentation
      module Padrino

        if RUBY_VERSION < "2.7.0"
          def invoke_route_with_newrelic(*args, &block)
            begin
              env["newrelic.last_route"] = args[0].original_path
            rescue => e
              ::NewRelic::Agent.logger.debug("Failed determining last route in Padrino", e)
            end
  
            begin
              txn_name = ::NewRelic::Agent::Instrumentation::Sinatra::TransactionNamer.transaction_name_for_route(env, request)
              unless txn_name.nil?
                ::NewRelic::Agent::Transaction.set_default_transaction_name(
                  "#{self.class.name}/#{txn_name}", :sinatra)
              end
            rescue => e
              ::NewRelic::Agent.logger.debug("Failed during invoke_route to set transaction name", e)
            end
  
            invoke_route_without_newrelic(*args, &block)
          end
        else
          def invoke_route_with_newrelic(*args, **kwargs, &block)
            begin
              env["newrelic.last_route"] = args[0].original_path
            rescue => e
              ::NewRelic::Agent.logger.debug("Failed determining last route in Padrino", e)
            end
  
            begin
              txn_name = ::NewRelic::Agent::Instrumentation::Sinatra::TransactionNamer.transaction_name_for_route(env, request)
              unless txn_name.nil?
                ::NewRelic::Agent::Transaction.set_default_transaction_name(
                  "#{self.class.name}/#{txn_name}", :sinatra)
              end
            rescue => e
              ::NewRelic::Agent.logger.debug("Failed during invoke_route to set transaction name", e)
            end
  
            invoke_route_without_newrelic(*args, **kwargs, &block)
          end
        end

      end
    end
  end
end
