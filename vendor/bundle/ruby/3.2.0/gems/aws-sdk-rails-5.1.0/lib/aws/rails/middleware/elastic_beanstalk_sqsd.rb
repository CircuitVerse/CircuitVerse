# frozen_string_literal: true

module Aws
  module Rails
    module Middleware
      # Middleware to handle requests from the SQS Daemon present on Elastic Beanstalk worker environments.
      class ElasticBeanstalkSQSD
        def initialize(app)
          @app = app
          @logger = ::Rails.logger

          return unless ENV['AWS_PROCESS_BEANSTALK_WORKER_JOBS_ASYNC']

          @executor = init_executor
        end

        def call(env)
          request = ::ActionDispatch::Request.new(env)

          # Pass through unless user agent is the SQS Daemon
          return @app.call(env) unless from_sqs_daemon?(request)

          @logger.debug('aws-sdk-rails middleware detected call from Elastic Beanstalk SQS Daemon.')

          # Only accept requests from this user agent if it is from localhost or a docker host in case of forgery.
          unless request.local? || sent_from_docker_host?(request)
            @logger.warn('SQSD request detected from untrusted address; returning 403 forbidden.')
            return forbidden_response
          end

          # Execute job or periodic task based on HTTP request context
          execute(request)
        end

        def shutdown(timeout = nil)
          return unless @executor

          @logger.info("Shutting down SQS EBS background job executor. Timeout: #{timeout}")
          @executor.shutdown
          clean_shutdown = @executor.wait_for_termination(timeout)
          @logger.info("SQS EBS background executor shutdown complete. Clean: #{clean_shutdown}")
        end

        private

        def init_executor
          threads = Integer(ENV.fetch('AWS_PROCESS_BEANSTALK_WORKER_THREADS',
                                      Concurrent.available_processor_count || Concurrent.processor_count))
          options = {
            max_threads: threads,
            max_queue: 1,
            auto_terminate: false, # register our own at_exit to gracefully shutdown
            fallback_policy: :abort # Concurrent::RejectedExecutionError must be handled
          }
          at_exit { shutdown }

          Concurrent::ThreadPoolExecutor.new(options)
        end

        def execute(request)
          if periodic_task?(request)
            execute_periodic_task(request)
          else
            execute_job(request)
          end
        end

        def execute_job(request)
          if @executor
            _execute_job_background(request)
          else
            _execute_job_now(request)
          end
        end

        # Execute a job in the current thread
        def _execute_job_now(request)
          # Jobs queued from the SQS adapter contain the JSON message in the request body.
          job = ::ActiveSupport::JSON.decode(request.body.string)
          job_name = job['job_class']
          @logger.debug("Executing job: #{job_name}")
          ::ActiveJob::Base.execute(job)
          [200, { 'Content-Type' => 'text/plain' }, ["Successfully ran job #{job_name}."]]
        rescue NameError => e
          @logger.error("Job #{job_name} could not resolve to a class that inherits from Active Job.")
          @logger.error("Error: #{e}")
          internal_error_response
        end

        # Execute a job using the thread pool executor
        def _execute_job_background(request)
          job_data = ::ActiveSupport::JSON.decode(request.body.string)
          @logger.debug("Queuing background job: #{job_data['job_class']}")
          @executor.post(job_data) do |job|
            ::ActiveJob::Base.execute(job)
          end
          [200, { 'Content-Type' => 'text/plain' }, ["Successfully queued job #{job_data['job_class']}"]]
        rescue Concurrent::RejectedExecutionError
          msg = 'No capacity to execute job.'
          @logger.info(msg)
          [429, { 'Content-Type' => 'text/plain' }, [msg]]
        end

        def execute_periodic_task(request)
          # The beanstalk worker SQS Daemon will add the 'X-Aws-Sqsd-Taskname' for periodic tasks set in cron.yaml.
          job_name = request.headers['X-Aws-Sqsd-Taskname']
          job = job_name.constantize.new
          if @executor
            _execute_periodic_task_background(job)
          else
            _execute_periodic_task_now(job)
          end
        rescue NameError => e
          @logger.error("Periodic task #{job_name} could not resolve to an Active Job class " \
                        '- check the cron name spelling and set the path as / in cron.yaml.')
          @logger.error("Error: #{e}.")
          internal_error_response
        end

        def _execute_periodic_task_now(job)
          @logger.debug("Executing periodic task: #{job.class}")
          job.perform_now
          [200, { 'Content-Type' => 'text/plain' }, ["Successfully ran periodic task #{job.class}."]]
        end

        def _execute_periodic_task_background(job)
          @logger.debug("Queuing bakground periodic task: #{job.class}")
          @executor.post(job, &:perform_now)
          [200, { 'Content-Type' => 'text/plain' }, ["Successfully queued periodic task #{job.class}"]]
        rescue Concurrent::RejectedExecutionError
          msg = 'No capacity to execute periodic task.'
          @logger.info(msg)
          [429, { 'Content-Type' => 'text/plain' }, [msg]]
        end

        def internal_error_response
          message = 'Failed to execute job - see Rails log for more details.'
          [500, { 'Content-Type' => 'text/plain' }, [message]]
        end

        def forbidden_response
          message = 'Request with aws-sqsd user agent was made from untrusted address.'
          [403, { 'Content-Type' => 'text/plain' }, [message]]
        end

        # The beanstalk worker SQS Daemon sets a specific User-Agent headers that begins with 'aws-sqsd'.
        def from_sqs_daemon?(request)
          current_user_agent = request.headers['User-Agent']

          !current_user_agent.nil? && current_user_agent.start_with?('aws-sqsd')
        end

        # The beanstalk worker SQS Daemon will add the custom 'X-Aws-Sqsd-Taskname' header
        # for periodic tasks set in cron.yaml.
        def periodic_task?(request)
          request.headers['X-Aws-Sqsd-Taskname'].present? && request.fullpath == '/'
        end

        def sent_from_docker_host?(request)
          app_runs_in_docker_container? && ip_originates_from_docker_host?(request)
        end

        def app_runs_in_docker_container?
          @app_runs_in_docker_container ||= in_docker_container_with_cgroup1? || in_docker_container_with_cgroup2?
        end

        def in_docker_container_with_cgroup1?
          File.exist?('/proc/1/cgroup') && File.read('/proc/1/cgroup') =~ %r{/docker/}
        end

        def in_docker_container_with_cgroup2?
          File.exist?('/proc/self/mountinfo') && File.read('/proc/self/mountinfo') =~ %r{/docker/containers/}
        end

        def ip_originates_from_docker_host?(request)
          default_docker_ips.include?(request.remote_ip) ||
            default_docker_ips.include?(request.remote_addr)
        end

        def default_docker_ips
          @default_docker_ips ||= build_default_docker_ips
        end

        # rubocop:disable Metrics/AbcSize
        def build_default_docker_ips
          default_gw_ips = ['172.17.0.1']

          if File.exist?('/proc/net/route')
            File.open('/proc/net/route').each_line do |line|
              fields = line.strip.split
              next if fields.size != 11
              # Destination == 0.0.0.0 and Flags & RTF_GATEWAY != 0
              next unless fields[1] == '00000000' && fields[3].hex.anybits?(0x2)

              default_gw_ips << IPAddr.new_ntoh([fields[2].hex].pack('L')).to_s
            end
          end

          default_gw_ips
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
