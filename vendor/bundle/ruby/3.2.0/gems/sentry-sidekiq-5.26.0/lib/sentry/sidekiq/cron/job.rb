# frozen_string_literal: true

# Try requiring sidekiq-cron to ensure it's loaded before the integration.
# If sidekiq-cron is not available, do nothing.
begin
  require "sidekiq-cron"
rescue LoadError
  return
end

module Sentry
  module Sidekiq
    module Cron
      module Job
        def self.enqueueing_method
          ::Sidekiq::Cron::Job.instance_methods.include?(:enque!) ? :enque! : :enqueue!
        end

        define_method(enqueueing_method) do |*args|
          # make sure the current thread has a clean hub
          Sentry.clone_hub_to_current_thread

          Sentry.with_scope do |scope|
            Sentry.with_session_tracking do
              begin
                scope.set_transaction_name("#{name} (#{klass})")

                transaction = start_transaction(scope)
                scope.set_span(transaction) if transaction
                super(*args)

                finish_transaction(transaction, 200)
              rescue
                finish_transaction(transaction, 500)
                raise
              end
            end
          end
        end

        def save
          # validation failed, do nothing
          return false unless super

          # fail gracefully if can't find class
          klass_const =
            begin
              if ::Sidekiq::Cron::Support.respond_to?(:safe_constantize)
                ::Sidekiq::Cron::Support.safe_constantize(klass.to_s)
              else
                ::Sidekiq::Cron::Support.constantize(klass.to_s)
              end
            rescue NameError
              return true
            end

          return true if klass_const.nil? # Sidekiq::Cron returns nil if class is not found

          # only patch if not explicitly included in job by user
          unless klass_const.send(:ancestors).include?(Sentry::Cron::MonitorCheckIns)
            klass_const.send(:include, Sentry::Cron::MonitorCheckIns)
            klass_const.send(:sentry_monitor_check_ins,
                             slug: name.to_s,
                             monitor_config: Sentry::Sidekiq::Cron::Helpers.monitor_config(parsed_cron.original))
          end

          true
        end

        def start_transaction(scope)
          Sentry.start_transaction(
            name: scope.transaction_name,
            source: scope.transaction_source,
            op: "queue.sidekiq-cron",
            origin: "auto.queue.sidekiq.cron"
          )
        end

        def finish_transaction(transaction, status_code)
          return unless transaction

          transaction.set_http_status(status_code)
          transaction.finish
        end
      end
    end
  end
end

Sentry.register_patch(:sidekiq_cron, Sentry::Sidekiq::Cron::Job, ::Sidekiq::Cron::Job)
