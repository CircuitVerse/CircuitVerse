# frozen_string_literal: true

require 'aws-sdk-sqs'
require 'concurrent'

module ActiveJob
  module QueueAdapters

    # == Async adapter for Amazon SQS ActiveJob
    #
    # This adapter queues jobs asynchronously (ie non-blocking).  Error handler can be configured
    # with +Aws::Rails::SqsActiveJob.config.async_queue_error_handler+.
    #
    # To use this adapter, set up as:
    #
    # config.active_job.queue_adapter = :amazon_sqs_async
    class AmazonSqsAsyncAdapter < AmazonSqsAdapter

      private

      def _enqueue(job, body = nil, send_message_opts = {})
        # FIFO jobs must be queued in order, so do not queue async
        queue_url = Aws::Rails::SqsActiveJob.config.queue_url_for(job.queue_name)
        if Aws::Rails::SqsActiveJob.fifo?(queue_url)
          super(job, body, send_message_opts)
        else
          # Serialize is called here because the job’s locale needs to be
          # determined in this thread and not in some other thread.
          body = job.serialize
          Concurrent::Promises
            .future { super(job, body, send_message_opts) }
            .rescue do |e|
              Rails.logger.error "Failed to queue job #{job}. Reason: #{e}"
              error_handler = Aws::Rails::SqsActiveJob.config.async_queue_error_handler
              error_handler&.call(e, job, send_message_opts)
            end
        end
      end
    end
  end
end
