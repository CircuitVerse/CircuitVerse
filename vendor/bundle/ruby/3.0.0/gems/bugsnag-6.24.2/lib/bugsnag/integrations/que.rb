require 'que'
if defined?(::Que)
  handler = proc do |error, job|
    begin
      job &&= job.dup # Make sure the original job object is not mutated.

      Bugsnag.notify(error, true) do |report|
        if job
          job[:error_count] += 1

          # If the job was scheduled using ActiveJob then unwrap the job details for clarity:
          if job[:job_class] == "ActiveJob::QueueAdapters::QueAdapter::JobWrapper"
            wrapped_job = job[:args].last
            wrapped_job = wrapped_job.each_with_object({}) { |(k, v), result| result[k.to_sym] = v } # Symbolize keys

            # Align key names with keys in `job`
            wrapped_job[:queue] = wrapped_job.delete(:queue_name)
            wrapped_job[:args]  = wrapped_job.delete(:arguments)

            job.merge!(wrapper_job_class: job[:job_class], wrapper_job_id: job[:job_id]).merge!(wrapped_job)
          end
        end

        report.add_tab(:job, job)
        report.severity = 'error'
        report.severity_reason = {
          :type => Bugsnag::Report::UNHANDLED_EXCEPTION_MIDDLEWARE,
          :attributes => {
            :framework => 'Que'
          }
        }
      end
    rescue => e
      # Que supresses errors raised by its error handler to avoid killing the worker. Log them somewhere:
      Bugsnag.configuration.warn("Failed to notify Bugsnag of error in Que job (#{e.class}): #{e.message} \n#{e.backtrace[0..9].join("\n")}")
      raise
    end
  end

  Bugsnag.configuration.detected_app_type = "que"

  if defined?(::Que::Version)
    Bugsnag.configuration.runtime_versions["que"] = ::Que::Version
  elsif defined?(::Que::VERSION)
    Bugsnag.configuration.runtime_versions["que"] = ::Que::VERSION
  end

  if Que.respond_to?(:error_notifier=)
    Que.error_notifier = handler
  elsif Que.respond_to?(:error_handler=)
    Que.error_handler = handler
  end
end
