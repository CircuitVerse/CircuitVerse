# frozen_string_literal: true

require 'active_support/notifications'

require 'aws-sdk-core'

module Aws
  module Rails
    # @api private
    class Notifications < Seahorse::Client::Plugin
      # This plugin needs to be first, which means it is called first in the stack,
      # to start recording time, and returns last
      def add_handlers(handlers, _config)
        handlers.add(Handler, step: :initialize, priority: 99)
      end

      # @api private
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
