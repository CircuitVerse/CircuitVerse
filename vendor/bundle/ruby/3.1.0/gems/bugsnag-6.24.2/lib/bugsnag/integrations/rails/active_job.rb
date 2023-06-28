require 'set'

module Bugsnag::Rails
  module ActiveJob
    SEVERITY = 'error'
    SEVERITY_REASON = {
      type: Bugsnag::Report::UNHANDLED_EXCEPTION_MIDDLEWARE,
      attributes: { framework: 'Active Job' }
    }

    EXISTING_INTEGRATIONS = Set[
      'ActiveJob::QueueAdapters::DelayedJobAdapter',
      'ActiveJob::QueueAdapters::QueAdapter',
      'ActiveJob::QueueAdapters::ResqueAdapter',
      'ActiveJob::QueueAdapters::ShoryukenAdapter',
      'ActiveJob::QueueAdapters::SidekiqAdapter'
    ]

    INLINE_ADAPTER = 'ActiveJob::QueueAdapters::InlineAdapter'

    # these methods were added after the first Active Job release so
    # may not be present, depending on the Rails version
    MAYBE_MISSING_METHODS = [
      :provider_job_id,
      :priority,
      :executions,
      :enqueued_at,
      :timezone
    ]

    def self.included(base)
      base.class_eval do
        around_perform do |job, block|
          adapter = _bugsnag_get_adapter_name(job)

          # if we have an integration for this queue adapter already then we should
          # leave this job alone or we'll end up with duplicate metadata
          next block.call if EXISTING_INTEGRATIONS.include?(adapter)

          Bugsnag.configuration.detected_app_type = 'active job'

          begin
            Bugsnag.configuration.set_request_data(:active_job, _bugsnag_extract_metadata(job))

            block.call
          rescue Exception => e
            Bugsnag.notify(e, true) do |report|
              report.severity = SEVERITY
              report.severity_reason = SEVERITY_REASON
            end

            # when using the "inline" adapter the job is run immediately, which
            # will result in our Rack integration catching the re-raised error
            # and reporting it a second time if it's run in a web request
            if adapter == INLINE_ADAPTER
              e.instance_eval do
                def skip_bugsnag
                  true
                end
              end
            end

            raise
          ensure
            Bugsnag.configuration.clear_request_data
          end
        end
      end
    end

    private

    def _bugsnag_get_adapter_name(job)
      adapter = job.class.queue_adapter

      # in Rails 4 queue adapters were references to a class. In Rails 5+
      # they are an instance of that class instead
      return adapter.name if adapter.is_a?(Class)

      adapter.class.name
    end

    def _bugsnag_extract_metadata(job)
      metadata = {
        job_id: job.job_id,
        job_name: job.class.name,
        queue: job.queue_name,
        arguments: job.arguments,
        locale: job.locale
      }

      MAYBE_MISSING_METHODS.each do |method_name|
        next unless job.respond_to?(method_name)

        metadata[method_name] = job.send(method_name)
      end

      metadata.compact!
      metadata
    end
  end
end
