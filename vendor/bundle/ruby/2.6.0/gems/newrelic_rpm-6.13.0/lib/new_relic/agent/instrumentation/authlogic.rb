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
  end

  executes do
    Authlogic::Session::Base.class_eval do
      class << self
        add_method_tracer :find, 'Custom/Authlogic/find'
      end
    end
  end
end
