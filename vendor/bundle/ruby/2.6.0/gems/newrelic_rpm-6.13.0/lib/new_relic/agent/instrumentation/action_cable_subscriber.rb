# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.
require 'new_relic/agent/instrumentation/notifications_subscriber'

module NewRelic
  module Agent
    module Instrumentation
      class ActionCableSubscriber < NotificationsSubscriber

        PERFORM_ACTION = 'perform_action.action_cable'.freeze

        def start(name, id, payload) #THREAD_LOCAL_ACCESS
          return unless state.is_execution_traced?

          finishable = if name == PERFORM_ACTION
            Tracer.start_transaction_or_segment(
              name: transaction_name_from_payload(payload),
              category: :action_cable
            )
          else
            Tracer.start_segment(name: metric_name_from_payload(name, payload))
          end
          push_segment(id, finishable)
        rescue => e
          log_notification_error e, name, 'start'
        end

        def finish(name, id, payload) #THREAD_LOCAL_ACCESS
          return unless state.is_execution_traced?

          if exception = exception_object(payload)
            NewRelic::Agent.notice_error exception
          end

          finishable = pop_segment(id)
          finishable.finish if finishable
        rescue => e
          log_notification_error e, name, 'finish'
        end

        private

        def transaction_name_from_payload(payload)
          "Controller/ActionCable/#{payload[:channel_class]}/#{payload[:action]}"
        end

        def metric_name_from_payload(name, payload)
          "Ruby/ActionCable/#{payload[:channel_class]}/#{action_name(name)}"
        end

        DOT_ACTION_CABLE = '.action_cable'.freeze

        def action_name(name)
          name.gsub DOT_ACTION_CABLE, NewRelic::EMPTY_STR
        end
      end
    end
  end
end
