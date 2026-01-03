# frozen_string_literal: true

module Sentry
  module Rails
    module ControllerTransaction
      SPAN_ORIGIN = "auto.view.rails"

      def self.included(base)
        base.prepend_around_action(:sentry_around_action)
      end

      private

      def sentry_around_action
        if Sentry.initialized?
          transaction_name = "#{self.class}##{action_name}"
          Sentry.get_current_scope.set_transaction_name(transaction_name, source: :view)
          Sentry.with_child_span(op: "view.process_action.action_controller", description: transaction_name, origin: SPAN_ORIGIN) do |child_span|
            if child_span
              begin
                result = yield
              ensure
                child_span.set_http_status(response.status)
                child_span.set_data(:format, request.format)
                child_span.set_data(:method, request.method)

                pii = Sentry.configuration.send_default_pii
                child_span.set_data(:path, pii ? request.fullpath : request.filtered_path)
                child_span.set_data(:params, pii ? request.params : request.filtered_parameters)
              end

              result
            else
              yield
            end
          end
        else
          yield
        end
      end
    end
  end
end
