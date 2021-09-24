# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'set'

DependencyDetection.defer do
  @name = :merb_controller

  depends_on do
    defined?(Merb) && defined?(Merb::Controller)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Merb Controller instrumentation'
  end

  executes do
    require 'merb-core/controller/merb_controller'

    Merb::Controller.class_eval do
      include NewRelic::Agent::Instrumentation::ControllerInstrumentation

      # determine the path that is used in the metric name for
      # the called controller action
      def newrelic_metric_path
        "#{controller_name}/#{action_name}"
      end

      protected

      def _dispatch_with_newrelic_trace(*args)
        options = {}
        options[:params] = params
        perform_action_with_newrelic_trace(options) do
          _dispatch_without_newrelic_trace(*args)
        end
      end

      alias_method :_dispatch_without_newrelic_trace, :_dispatch
      alias_method :_dispatch, :_dispatch_with_newrelic_trace
    end
  end
end
