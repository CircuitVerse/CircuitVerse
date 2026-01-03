# frozen_string_literal: true

# Try to require sidekiq-scheduler to make sure it's loaded before the integration.
begin
  require "sidekiq-scheduler"
rescue LoadError
  return
end

# If we've loaded sidekiq-scheduler, but the API changed,
# and the Scheduler class is not there, fail gracefully.
return unless defined?(::SidekiqScheduler::Scheduler)

module Sentry
  module SidekiqScheduler
    module Scheduler
      def new_job(name, interval_type, config, schedule, options)
        # Schedule the job upstream first
        # SidekiqScheduler does not validate schedules
        # It will fail with an error if the schedule in the config is invalid.
        # If this errors out, let it fall through.
        rufus_job = super

        klass = config.fetch("class")
        return rufus_job unless klass

        # Constantize the job class, and fail gracefully if it could not be found
        klass_const =
          begin
            Object.const_get(klass)
          rescue NameError
            return rufus_job
          end

        # For cron, every, or interval jobs — grab their schedule.
        # Rufus::Scheduler::EveryJob stores it's frequency in seconds,
        # so we convert it to minutes before passing in to the monitor.
        monitor_config =
          case interval_type
          when "cron"
            Sentry::Sidekiq::Cron::Helpers.monitor_config(schedule)
          when "every", "interval"
            Sentry::Cron::MonitorConfig.from_interval(rufus_job.frequency.to_i / 60, :minute)
          end

        # If we couldn't build a monitor config, it's either an error, or
        # it's a one-time job (interval_type is in, or at), in which case
        # we should not make a monitof for it automaticaly.
        return rufus_job if monitor_config.nil?

        # only patch if not explicitly included in job by user
        unless klass_const.send(:ancestors).include?(Sentry::Cron::MonitorCheckIns)
          klass_const.send(:include, Sentry::Cron::MonitorCheckIns)
          slug = klass_const.send(:sentry_monitor_slug, name: name)
          klass_const.send(:sentry_monitor_check_ins,
                           slug: slug,
                           monitor_config: monitor_config)

          ::Sidekiq.logger.info "Injected Sentry Crons monitor checkins into #{klass}"
        end

        rufus_job
      end
    end
  end
end

Sentry.register_patch(:sidekiq_scheduler, Sentry::SidekiqScheduler::Scheduler, ::SidekiqScheduler::Scheduler)
