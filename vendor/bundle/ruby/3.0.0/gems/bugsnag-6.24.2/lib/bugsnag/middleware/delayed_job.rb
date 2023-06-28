module Bugsnag::Middleware
  ##
  # Attaches delayed_job information to an error report
  class DelayedJob
    # Active Job's queue adapter sets the "display_name" to this format. This
    # breaks the event context as the ID and arguments are included, which will
    # differ between executions of the same job
    ACTIVE_JOB_DISPLAY_NAME = /^.* \[[0-9a-f-]+\] from DelayedJob\(.*\) with arguments: \[.*\]$/

    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(report)
      job = report.request_data[:delayed_job]
      if job
        job_data = {
          :class => job.class.name,
          :id => job.id
        }
        job_data[:priority] = job.priority if job.respond_to?(:priority)
        job_data[:run_at] = job.run_at if job.respond_to?(:run_at)
        job_data[:locked_at] = job.locked_at if job.respond_to?(:locked_at)
        job_data[:locked_by] = job.locked_by if job.respond_to?(:locked_by)
        job_data[:created_at] = job.created_at if job.respond_to?(:created_at)
        job_data[:queue] = job.queue if job.respond_to?(:queue)

        if job.respond_to?(:payload_object)
          job_data[:active_job] = job.payload_object.job_data if job.payload_object.respond_to?(:job_data)
          payload_data = construct_job_payload(job.payload_object)

          context = get_context(payload_data, job_data[:active_job])
          report.automatic_context = context unless context.nil?

          job_data[:payload] = payload_data
        end

        if job.respond_to?(:attempts)
          # +1 as "attempts" is zero-based and does not include the current failed attempt
          job_data[:attempt] = job.attempts + 1
          job_data[:max_attempts] = (job.respond_to?(:max_attempts) && job.max_attempts) || Delayed::Worker.max_attempts
        end

        report.add_tab(:job, job_data)
      end
      @bugsnag.call(report)
    end

    def construct_job_payload(payload)
      data = {
        :class => payload.class.name
      }
      data[:id]           = payload.id           if payload.respond_to?(:id)
      data[:display_name] = payload.display_name if payload.respond_to?(:display_name)
      data[:method_name]  = payload.method_name  if payload.respond_to?(:method_name)

      if payload.respond_to?(:args)
        data[:args] = payload.args
      elsif payload.respond_to?(:to_h)
        data[:args] = payload.to_h
      elsif payload.respond_to?(:instance_values)
        data[:args] = payload.instance_values
      end

      if payload.is_a?(::Delayed::PerformableMethod) && (object = payload.object)
        data[:object] = {
          :class => object.class.name
        }
        data[:object][:id] = object.id if object.respond_to?(:id)
      end
      if payload.respond_to?(:job_data) && payload.job_data.respond_to?(:[])
        [:job_class, :arguments, :queue_name, :job_id].each do |key|
          if (value = payload.job_data[key.to_s])
            data[key] = value
          end
        end
      end
      data
    end

    private

    def get_context(payload_data, active_job_data)
      if payload_data.include?(:display_name) && !ACTIVE_JOB_DISPLAY_NAME.match?(payload_data[:display_name])
        payload_data[:display_name]
      elsif active_job_data && active_job_data['job_class'] && active_job_data['queue_name']
        "#{active_job_data['job_class']}@#{active_job_data['queue_name']}"
      elsif payload_data.include?(:class)
        payload_data[:class]
      end
    end
  end
end
