# frozen_string_literal: true

require 'concurrent'

module Aws
  module Rails
    module SqsActiveJob
      # CLI runner for polling for SQS ActiveJobs
      class Executor

        DEFAULTS = {
           min_threads:     0,
           max_threads:     Concurrent.processor_count,
           auto_terminate:  true,
           idletime:        60, # 1 minute
           fallback_policy: :caller_runs # slow down the producer thread
        }.freeze

        def initialize(options = {})
          @executor = Concurrent::ThreadPoolExecutor.new(DEFAULTS.merge(options))
          @logger = options[:logger] || ActiveSupport::Logger.new(STDOUT)
        end

        # TODO: Consider catching the exception and sleeping instead of using :caller_runs
        def execute(message)
          @executor.post(message) do |message|
            begin
              job = JobRunner.new(message)
              @logger.info("Running job: #{job.id}[#{job.class_name}]")
              job.run
              message.delete
            rescue Aws::Json::ParseError => e
              @logger.error "Unable to parse message body: #{message.data.body}. Error: #{e}."
            rescue StandardError => e
              # message will not be deleted and will be retried
              job_msg = job ? "#{job.id}[#{job.class_name}]" : 'unknown job'
              @logger.info "Error processing job #{job_msg}: #{e}"
              @logger.debug e.backtrace.join("\n")
            end
          end
        end

        def shutdown(timeout=nil)
          @executor.shutdown
          clean_shutdown = @executor.wait_for_termination(timeout)
          if clean_shutdown
            @logger.info 'Clean shutdown complete.  All executing jobs finished.'
          else
            @logger.info "Timeout (#{timeout}) exceeded.  Some jobs may not have"\
              " finished cleanly.  Unfinished jobs will not be removed from"\
              " the queue and can be ru-run once their visibility timeout"\
              " passes."
          end
        end
      end
    end
  end
end
