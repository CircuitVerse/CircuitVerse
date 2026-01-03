# frozen_string_literal: true

module Sentry
  class Configuration
    attr_reader :sidekiq

    add_post_initialization_callback do
      @sidekiq = Sentry::Sidekiq::Configuration.new
      @excluded_exceptions = @excluded_exceptions.concat(Sentry::Sidekiq::IGNORE_DEFAULT)
    end
  end

  module Sidekiq
    IGNORE_DEFAULT = [
      "Sidekiq::JobRetry::Skip",
      "Sidekiq::JobRetry::Handled"
    ]

    class Configuration
      # Set this option to true if you want Sentry to only capture the last job
      # retry if it fails.
      attr_accessor :report_after_job_retries

      # Only report jobs that don't have `dead: false` set in the job's `sidekiq_options`
      attr_accessor :report_only_dead_jobs

      # Whether we should inject headers while enqueuing the job in order to have a connected trace
      attr_accessor :propagate_traces

      def initialize
        @report_after_job_retries = false
        @report_only_dead_jobs = false
        @propagate_traces = true
      end
    end
  end
end
