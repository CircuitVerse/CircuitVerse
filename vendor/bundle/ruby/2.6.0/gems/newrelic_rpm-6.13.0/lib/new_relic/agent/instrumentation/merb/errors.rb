# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

DependencyDetection.defer do
  @name = :merb_error

  depends_on do
    defined?(Merb) && defined?(Merb::Dispatcher) && defined?(Merb::Dispatcher::DefaultException)
  end

  depends_on do
    Merb::Dispatcher::DefaultException.respond_to?(:before)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Merb Errors instrumentation'
  end

  executes do

    # Hook in the notification to merb
    error_notifier = Proc.new {
      if request.exceptions #check that there's actually an exception
        # Note, this assumes we have already captured the other information such as uri and params in the Transaction.
        NewRelic::Agent::Transaction.notice_error(request.exceptions.first)
      end
    }
    Merb::Dispatcher::DefaultException.before error_notifier
    Exceptions.before error_notifier

  end
end
