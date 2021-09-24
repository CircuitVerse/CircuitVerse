# frozen_string_literal: true

module Aws
  module Rails
    # Middleware to handle requests from the SQS Daemon present on Elastic Beanstalk worker environments.
    class EbsSqsActiveJobMiddleware
      INTERNAL_ERROR_MESSAGE = 'Failed to execute job - see Rails log for more details.'
      INTERNAL_ERROR_RESPONSE = [500, { 'Content-Type' => 'text/plain' }, [INTERNAL_ERROR_MESSAGE]].freeze
      FORBIDDEN_MESSAGE = 'Request with aws-sqsd user agent was made from untrusted address.'
      FORBIDDEN_RESPONSE = [403, { 'Content-Type' => 'text/plain' }, [FORBIDDEN_MESSAGE]].freeze

      def initialize(app)
        @app = app
        @logger = ActiveSupport::Logger.new(STDOUT)
      end

      def call(env)
        request = ActionDispatch::Request.new(env)

        # Pass through unless user agent is the SQS Daemon
        return @app.call(env) unless from_sqs_daemon?(request)

        @logger.debug('aws-rails-sdk middleware detected call from Elastic Beanstalk SQS Daemon.')

        # Only accept requests from this user agent if it is from localhost or a docker host in case of forgery.
        unless request.local? || sent_from_docker_host?(request)
          @logger.warn("SQSD request detected from untrusted address #{request.remote_ip}; returning 403 forbidden.")
          return FORBIDDEN_RESPONSE
        end

        # Execute job or periodic task based on HTTP request context
        periodic_task?(request) ? execute_periodic_task(request) : execute_job(request)
      end

      private

      def execute_job(request)
        # Jobs queued from the Active Job SQS adapter contain the JSON message in the request body.
        job = Aws::Json.load(request.body.string)
        job_name = job['job_class']
        @logger.debug("Executing job: #{job_name}")

        begin
          ActiveJob::Base.execute(job)
        rescue NoMethodError, NameError => e
          @logger.error("Job #{job_name} could not resolve to a class that inherits from Active Job.")
          @logger.error("Error: #{e}")
          return INTERNAL_ERROR_RESPONSE
        end

        [200, { 'Content-Type' => 'text/plain' }, ["Successfully ran job #{job_name}."]]
      end

      def execute_periodic_task(request)
        # The beanstalk worker SQS Daemon will add the 'X-Aws-Sqsd-Taskname' for periodic tasks set in cron.yaml.
        job_name = request.headers['X-Aws-Sqsd-Taskname']
        @logger.debug("Creating and executing periodic task: #{job_name}")

        begin
          job = job_name.constantize.new
          job.perform_now
        rescue NoMethodError, NameError => e
          @logger.error("Periodic task #{job_name} could not resolve to an Active Job class - check the spelling in cron.yaml.")
          @logger.error("Error: #{e}.")
          return INTERNAL_ERROR_RESPONSE
        end

        [200, { 'Content-Type' => 'text/plain' }, ["Successfully ran periodic task #{job_name}."]]
      end

      # The beanstalk worker SQS Daemon sets a specific User-Agent headers that begins with 'aws-sqsd'.
      def from_sqs_daemon?(request)
        current_user_agent = request.headers['User-Agent']

        !current_user_agent.nil? && current_user_agent.start_with?('aws-sqsd')
      end

      # The beanstalk worker SQS Daemon will add the custom 'X-Aws-Sqsd-Taskname' header for periodic tasks set in cron.yaml.
      def periodic_task?(request)
        !request.headers['X-Aws-Sqsd-Taskname'].nil? && request.headers['X-Aws-Sqsd-Taskname'].present?
      end

      def sent_from_docker_host?(request)
        app_runs_in_docker_container? && request.remote_ip == '172.17.0.1'
      end

      def app_runs_in_docker_container?
        @app_runs_in_docker_container ||= `[ -f /proc/1/cgroup ] && cat /proc/1/cgroup` =~ /docker/
      end
    end
  end
end
