require 'delayed_job'

# See Issue #99
unless defined?(Delayed::Plugin)
  raise LoadError, "bugsnag requires delayed_job > 3.x"
end

::Bugsnag.configuration.internal_middleware.use(::Bugsnag::Middleware::DelayedJob)

module Delayed
  module Plugins
    class Bugsnag < ::Delayed::Plugin
      ##
      # DelayedJob doesn't have an easy way to fetch its version, but we can use
      # Gem.loaded_specs to get the version instead
      def self.delayed_job_version
        ::Gem.loaded_specs['delayed_job'].version.to_s
      rescue StandardError
        # Explicitly return nil to prevent Rubocop complaining of a suppressed exception
        nil
      end

      callbacks do |lifecycle|
        lifecycle.around(:invoke_job) do |job, *args, &block|
          begin
            ::Bugsnag.configuration.detected_app_type = 'delayed_job'
            ::Bugsnag.configuration.runtime_versions['delayed_job'] = delayed_job_version if defined?(::Gem)
            ::Bugsnag.configuration.set_request_data(:delayed_job, job)

            block.call(job, *args)
          rescue Exception => exception
            ::Bugsnag.notify(exception, true) do |report|
              report.severity = "error"
              report.severity_reason = {
                :type => ::Bugsnag::Report::UNHANDLED_EXCEPTION_MIDDLEWARE,
                :attributes => {
                  :framework => "DelayedJob"
                }
              }
            end
            raise exception
          ensure
            ::Bugsnag.configuration.clear_request_data
          end
        end
      end
    end
  end
end

Delayed::Worker.plugins << Delayed::Plugins::Bugsnag
