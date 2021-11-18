# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'json'
require 'new_relic/agent/hostname'

module NewRelic
  module Agent
    module Logging

      # This class can be used as the formatter for an existing logger.  It
      # decorates log messages with trace and entity metadata, and formats each
      # log messages as a JSON object.
      #
      # It can be added to a Rails application like this:
      #
      #   require 'newrelic_rpm'
      #
      #   Rails.application.configure do
      #     config.log_formatter = ::NewRelic::Agent::Logging::DecoratingFormatter.new
      #   end
      #
      # @api public
      class DecoratingFormatter < ::Logger::Formatter
        TIMESTAMP_KEY = 'timestamp'.freeze
        MESSAGE_KEY = 'message'.freeze
        LOG_LEVEL_KEY = 'log.level'.freeze
        LOG_NAME_KEY = 'logger.name'.freeze
        NEWLINE = "\n".freeze

        QUOTE = '"'.freeze
        COLON = ':'.freeze
        COMMA = ','.freeze
        CLOSING_BRACE = '}'.freeze

        def initialize
          Agent.config.register_callback :app_name do
            @app_name = nil
          end
        end

        def call severity, time, progname, msg
          message = '{'
          if app_name
            add_key_value message, ENTITY_NAME_KEY, app_name
            message << COMMA
          end
          add_key_value message, ENTITY_TYPE_KEY, ENTITY_TYPE
          message << COMMA
          add_key_value message, HOSTNAME_KEY, Hostname.get

          if entity_guid = Agent.config[:entity_guid]
            message << COMMA
            add_key_value message, ENTITY_GUID_KEY, entity_guid
          end

          if trace_id = Tracer.trace_id
            message << COMMA
            add_key_value message, TRACE_ID_KEY, trace_id
          end
          if span_id = Tracer.span_id
            message << COMMA
            add_key_value message, SPAN_ID_KEY, span_id
          end

          message << COMMA
          message << QUOTE << MESSAGE_KEY << QUOTE << COLON << escape(msg)
          message << COMMA
          add_key_value message, LOG_LEVEL_KEY, severity
          if progname
            message << COMMA
            add_key_value message, LOG_NAME_KEY, progname
          end

          message << COMMA
          message << QUOTE << TIMESTAMP_KEY << QUOTE << COLON << (time.to_f * 1000).round.to_s
          message << CLOSING_BRACE << NEWLINE
        end

        def app_name
          @app_name ||= Agent.config[:app_name][0]
        end

        def add_key_value message, key, value
          message << QUOTE << key << QUOTE << COLON << QUOTE << value << QUOTE
        end

        def escape message
          if String === message
            message.to_json
          else
            message.inspect.to_json
          end
        end

        def clear_tags!
          # No-op; just avoiding issues with act-fluent-logger-rails
        end
      end


      # This logger decorates logs with trace and entity metadata, and emits log
      # messages formatted as JSON objects.  It extends the Logger class from
      # the Ruby standard library, and accepts the same constructor parameters.
      #
      # It aliases the `:info` message to overwrite the `:write` method, so it
      # can be used in Rack applications that expect the logger to be a file-like
      # object.
      #
      # It can be added to an application like this:
      #
      #   require 'newrelic_rpm'
      #
      #   config.logger = NewRelic::Agent::Logging::DecoratingLogger.new "log/application.log"
      #
      # @api public
      class DecoratingLogger < (defined?(::ActiveSupport) && defined?(::ActiveSupport::Logger) ? ::ActiveSupport::Logger : ::Logger)

        alias :write :info

        # Positional and Keyword arguments are separated beginning with Ruby 2.7
        # Signature of ::Logger constructor changes in Ruby 2.4 to have both positional and keyword args
        # We pivot on Ruby 2.7 for widest supportability with least amount of hassle.
        if RUBY_VERSION < "2.7.0"
          def initialize(*args)
            super(*args)
            self.formatter = DecoratingFormatter.new
          end
        else
          def initialize(*args, **kwargs)
            super(*args, **kwargs)
            self.formatter = DecoratingFormatter.new
          end
        end
      end
    end
  end
end
