# frozen_string_literal: true

module Sentry
  # The StructuredLogger class implements Sentry's SDK telemetry logs protocol.
  # It provides methods for logging messages at different severity levels and
  # sending them to Sentry with structured data.
  #
  # This class follows the Sentry Logs Protocol as defined in:
  # https://develop.sentry.dev/sdk/telemetry/logs/
  #
  # @example Basic usage
  #   Sentry.logger.info("User logged in", user_id: 123)
  #
  # @example With structured data
  #   Sentry.logger.warn("API request failed",
  #     status_code: 404,
  #     endpoint: "/api/users",
  #     request_id: "abc-123"
  #   )
  #
  # @example With a message template
  #   # Using positional parameters
  #   Sentry.logger.info("User %s logged in", ["Jane Doe"])
  #
  #   # Using hash parameters
  #   Sentry.logger.info("User %{name} logged in", name: "Jane Doe")
  #
  #   # Using hash parameters and extra attributes
  #   Sentry.logger.info("User %{name} logged in", name: "Jane Doe", user_id: 312)
  #
  # @see https://develop.sentry.dev/sdk/telemetry/logs/ Sentry SDK Telemetry Logs Protocol
  class StructuredLogger
    # Severity number mapping for log levels according to the Sentry Logs Protocol
    # @see https://develop.sentry.dev/sdk/telemetry/logs/#log-severity-number
    LEVELS = {
      trace: 1,
      debug: 5,
      info: 9,
      warn: 13,
      error: 17,
      fatal: 21
    }.freeze

    # @return [Configuration] The Sentry configuration
    # @!visibility private
    attr_reader :config

    # Initializes a new StructuredLogger instance
    #
    # @param config [Configuration] The Sentry configuration
    def initialize(config)
      @config = config
    end

    # Logs a message at TRACE level
    #
    # @param message [String] The log message
    # @param parameters [Array] Array of values to replace template parameters in the message
    # @param attributes [Hash] Additional attributes to include with the log
    #
    # @return [LogEvent, nil] The created log event or nil if logging is disabled
    def trace(message, parameters = [], **attributes)
      log(__method__, message, parameters: parameters, **attributes)
    end

    # Logs a message at DEBUG level
    #
    # @param message [String] The log message
    # @param parameters [Array] Array of values to replace template parameters in the message
    # @param attributes [Hash] Additional attributes to include with the log
    #
    # @return [LogEvent, nil] The created log event or nil if logging is disabled
    def debug(message, parameters = [], **attributes)
      log(__method__, message, parameters: parameters, **attributes)
    end

    # Logs a message at INFO level
    #
    # @param message [String] The log message
    # @param parameters [Array] Array of values to replace template parameters in the message
    # @param attributes [Hash] Additional attributes to include with the log
    #
    # @return [LogEvent, nil] The created log event or nil if logging is disabled
    def info(message, parameters = [], **attributes)
      log(__method__, message, parameters: parameters, **attributes)
    end

    # Logs a message at WARN level
    #
    # @param message [String] The log message
    # @param parameters [Array] Array of values to replace template parameters in the message
    # @param attributes [Hash] Additional attributes to include with the log
    #
    # @return [LogEvent, nil] The created log event or nil if logging is disabled
    def warn(message, parameters = [], **attributes)
      log(__method__, message, parameters: parameters, **attributes)
    end

    # Logs a message at ERROR level
    #
    # @param message [String] The log message
    # @param parameters [Array] Array of values to replace template parameters in the message
    # @param attributes [Hash] Additional attributes to include with the log
    #
    # @return [LogEvent, nil] The created log event or nil if logging is disabled
    def error(message, parameters = [], **attributes)
      log(__method__, message, parameters: parameters, **attributes)
    end

    # Logs a message at FATAL level
    #
    # @param message [String] The log message
    # @param parameters [Array] Array of values to replace template parameters in the message
    # @param attributes [Hash] Additional attributes to include with the log
    #
    # @return [LogEvent, nil] The created log event or nil if logging is disabled
    def fatal(message, parameters = [], **attributes)
      log(__method__, message, parameters: parameters, **attributes)
    end

    # Logs a message at the specified level
    #
    # @param level [Symbol] The log level (:trace, :debug, :info, :warn, :error, :fatal)
    # @param message [String] The log message
    # @param parameters [Array, Hash] Array or Hash of values to replace template parameters in the message
    # @param attributes [Hash] Additional attributes to include with the log
    #
    # @return [LogEvent, nil] The created log event or nil if logging is disabled
    def log(level, message, parameters:, **attributes)
      case parameters
      when Array then
        Sentry.capture_log(message, level: level, severity: LEVELS[level], parameters: parameters, **attributes)
      else
        Sentry.capture_log(message, level: level, severity: LEVELS[level], **parameters)
      end
    end
  end
end
