# frozen_string_literal: true

require 'aws-sdk-core'
require 'active_support/notifications'

module Aws
  module Rails

    # Instruments client operation calls for ActiveSupport::Notifications
    # Each client operation will produce an event with name:
    # <operation>.<service>.aws
    # @api private
    class Notifications < Seahorse::Client::Plugin

      def add_handlers(handlers, config)
        # This plugin needs to be first
        # which means it is called first in the stack, to start recording time,
        # and returns last
        handlers.add(Handler, step: :initialize, priority: 99)
      end

      class Handler < Seahorse::Client::Handler

        def call(context)
          event_name = "#{context.operation_name}.#{context.config.api.metadata['serviceId']}.aws"
          ActiveSupport::Notifications.instrument(event_name, context: context) do
            @handler.call(context)
          end
        end
      end
    end
  end
end
