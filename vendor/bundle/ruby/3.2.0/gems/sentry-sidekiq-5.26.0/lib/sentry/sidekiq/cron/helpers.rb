# frozen_string_literal: true

module Sentry
  module Sidekiq
    module Cron
      module Helpers
        # This is used by Cron::Job and Scheduler
        def self.monitor_config(cron)
          cron_parts = cron.strip.split(" ")

          if cron_parts.length > 5
            timezone = cron_parts.pop
            cron_without_timezone = cron_parts.join(" ")

            Sentry::Cron::MonitorConfig.from_crontab(cron_without_timezone, timezone: timezone)
          else
            Sentry::Cron::MonitorConfig.from_crontab(cron)
          end
        end
      end
    end
  end
end
