# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  module Agent
    module Instrumentation
      class NotificationsSubscriber
        def initialize
          @queue_key = ['NewRelic', self.class.name, object_id].join('-')
          define_exception_method
        end

        def self.subscribed?
          find_all_subscribers.find{|s| s.instance_variable_get(:@delegate).class == self }
        end

        def self.find_all_subscribers
          # TODO: need to talk to Rails core about an API for this,
          # rather than digging through Listener ivars
          instance_variable_names = [:@subscribers, :@string_subscribers, :@other_subscribers]
          all_subscribers = []

          notifier = ActiveSupport::Notifications.notifier

          instance_variable_names.each do |name|
            if notifier.instance_variable_defined?(name)
              subscribers = notifier.instance_variable_get(name)
              if subscribers.is_a? Array
                # Rails 5 @subscribers, and Rails 6 @other_subscribers is a
                # plain array of subscriber objects
                all_subscribers += subscribers
              elsif subscribers.is_a? Hash
                # Rails 6 @string_subscribers is a Hash mapping the pattern
                # string of a subscriber to an array of subscriber objects
                subscribers.values.each { |array| all_subscribers += array }
              end
            end
          end

          all_subscribers
        end

        def self.subscribe(pattern)
          if !subscribed?
            ActiveSupport::Notifications.subscribe(pattern, new)
          end
        end

        def log_notification_error(error, name, event_type)
          # These are important enough failures that we want the backtraces
          # logged at error level, hence the explicit log_exception call.
          NewRelic::Agent.logger.error("Error during #{event_type} callback for event '#{name}':")
          NewRelic::Agent.logger.log_exception(:error, error)
        end

        def push_segment(id, segment)
          segment_stack[id].push segment
        end

        def pop_segment(id)
          segment = segment_stack[id].pop
          segment
        end

        def segment_stack
          Thread.current[@queue_key] ||= Hash.new {|h,id| h[id] = [] }
        end

        def state
          NewRelic::Agent::Tracer.state
        end

        def define_exception_method
          # we don't expect this to be called more than once, but we're being
          # defensive.
          return if defined?(exception_object)
          return unless defined?(::ActiveSupport)
          if ::ActiveSupport::VERSION::STRING < "5.0.0"
            # Earlier versions of Rails did not add the exception itself to the
            # payload asssessible via :exception_object, so we create a stand-in
            # error object from the given class name and message.
            # NOTE: no backtrace available this way, but we can notice the error
            # well enough to send the necessary info the UI requires to present it.
            def exception_object(payload)
              exception_class, message = payload[:exception]
              return nil unless exception_class
              NewRelic::Agent::NoticibleError.new exception_class, message
            end
          else
            def exception_object(payload)
              payload[:exception_object]
            end
          end
        end
      end

    end
  end
end
