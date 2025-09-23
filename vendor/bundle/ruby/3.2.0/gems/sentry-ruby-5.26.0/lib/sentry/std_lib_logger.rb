# frozen_string_literal: true

module Sentry
  # Ruby Logger support Add commentMore actions
  # intercepts any logger instance and send the log to Sentry too.
  module StdLibLogger
    SEVERITY_MAP = {
      0 => :debug,
      1 => :info,
      2 => :warn,
      3 => :error,
      4 => :fatal
    }.freeze

    def add(severity, message = nil, progname = nil, &block)
      result = super

      return unless Sentry.initialized? && Sentry.get_current_hub

      # exclude sentry SDK logs -- to prevent recursive log action,
      # do not process internal logs again
      if message.nil? && progname != Sentry::Logger::PROGNAME

        # handle different nature of Ruby Logger class:
        # inspo from Sentry::Breadcrumb::SentryLogger
        if block_given?
          message = yield
        else
          message = progname
        end

        message = message.to_s.strip

        if !message.nil? && message != Sentry::Logger::PROGNAME && method = SEVERITY_MAP[severity]
          Sentry.logger.send(method, message)
        end
      end

      result
    end
  end
end

Sentry.register_patch(:logger) do |config|
  if config.enable_logs
    ::Logger.prepend(Sentry::StdLibLogger)
  else
    config.sdk_logger.warn(":logger patch enabled but `enable_logs` is turned off - skipping applying patch")
  end
end
