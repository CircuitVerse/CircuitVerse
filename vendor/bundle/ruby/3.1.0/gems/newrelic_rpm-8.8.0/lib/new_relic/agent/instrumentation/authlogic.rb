# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

DependencyDetection.defer do
  @name = :authlogic

  depends_on do
    defined?(Authlogic) &&
      defined?(Authlogic::Session) &&
      defined?(Authlogic::Session::Base)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Authlogic instrumentation'
    deprecation_msg = 'The instrumentation for Authlogic is deprecated. ' \
      'It will be removed in version 9.0.0.' \

    ::NewRelic::Agent.logger.log_once(
      :warn,
      :deprecated_authlogic,
      deprecation_msg
    )

    ::NewRelic::Agent.record_metric("Supportability/Deprecated/Authlogic", 1)
  end

  executes do
    Authlogic::Session::Base.class_eval do
      class << self
        add_method_tracer :find, 'Custom/Authlogic/find'
      end
    end
  end
end
