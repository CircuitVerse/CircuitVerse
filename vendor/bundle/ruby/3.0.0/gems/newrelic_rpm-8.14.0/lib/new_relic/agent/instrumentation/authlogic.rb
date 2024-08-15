# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.
# frozen_string_literal: true

DependencyDetection.defer do
  @name = :authlogic

  depends_on do
    defined?(Authlogic) &&
      defined?(Authlogic::Session) &&
      defined?(Authlogic::Session::Base)
  end

  executes do
    NewRelic::Agent.logger.info('Installing Authlogic instrumentation')
    deprecation_msg = 'The instrumentation for Authlogic is deprecated. ' \
      'It will be removed in version 9.0.0.' \

    NewRelic::Agent.logger.log_once(
      :warn,
      :deprecated_authlogic,
      deprecation_msg
    )
  end

  executes do
    Authlogic::Session::Base.class_eval do
      class << self
        add_method_tracer :find, 'Custom/Authlogic/find'
      end
    end
  end
end
