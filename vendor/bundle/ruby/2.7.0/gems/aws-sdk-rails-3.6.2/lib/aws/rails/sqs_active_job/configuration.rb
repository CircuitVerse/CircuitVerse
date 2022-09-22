# frozen_string_literal: true

module Aws
  module Rails
    module SqsActiveJob

      # @return [Configuration] the (singleton) Configuration
      def self.config
        @config ||= Configuration.new
      end

      # @yield Configuration
      def self.configure
        yield(config)
      end

      def self.fifo?(queue_url)
        queue_url.ends_with? '.fifo'
      end

      # Configuration for AWS SQS ActiveJob.
      # Use +Aws::Rails::SqsActiveJob.config+ to access the singleton config instance.
      class Configuration

        # Default configuration options
        # @api private
        DEFAULTS = {
          max_messages:  10,
          visibility_timeout: 120,
          shutdown_timeout: 15,
          queues: {},
          logger: ::Rails.logger,
          message_group_id: 'SqsActiveJobGroup'
        }

        # @api private
        attr_accessor :queues, :max_messages, :visibility_timeout,
                      :shutdown_timeout, :client, :logger,
                      :async_queue_error_handler, :message_group_id

        # Don't use this method directly: Confugration is a singleton class, use
        # +Aws::Rails::SqsActiveJob.config+ to access the singleton config.
        #
        # @param [Hash] options
        # @option options [Hash[Symbol, String]] :queues A mapping between the
        #   active job queue name and the SQS Queue URL. Note: multiple active
        #   job queues can map to the same SQS Queue URL.
        #
        # @option options  [Integer] :max_messages
        #    The max number of messages to poll for in a batch.
        #
        # @option options [Integer] :visibility_timeout
        #   The visibility timeout is the number of seconds
        #   that a message will not be processable by any other consumers.
        #   You should set this value to be longer than your expected job runtime
        #   to prevent other processes from picking up an running job.
        #   See the (SQS Visibility Timeout Documentation)[https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-visibility-timeout.html]
        #
        # @option options [Integer] :shutdown_timeout
        #   the amount of time to wait
        #   for a clean shutdown.  Jobs that are unable to complete in this time
        #   will not be deleted from the SQS queue and will be retryable after
        #   the visibility timeout.
        #
        # @option options [ActiveSupport::Logger] :logger Logger to use
        #   for the poller.
        #
        # @option options [String] :config_file
        #   Override file to load configuration from.  If not specified will
        #   attempt to load from config/aws_sqs_active_job.yml.
        #
        # @option options [String] :message_group_id (SqsActiveJobGroup)
        #  The message_group_id to use for queueing messages on a fifo queues.
        #  Applies only to jobs queued on FIFO queues.
        #  See the (SQS FIFO Documentation)[https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/FIFO-queues.html]
        #
        # @option options [Callable] :async_queue_error_handler An error handler
        #   to be called when the async active job adapter experiances an error
        #   queueing a job.  Only applies when
        #   +active_job.queue_adapter = :amazon_sqs_async+.  Called with:
        #   [error, job, job_options]
        #
        # @option options [SQS::Client] :client SQS Client to use.  A default
        #   client will be created if none is provided.
        def initialize(options = {})
          options[:config_file] ||= config_file if config_file.exist?
          options = DEFAULTS
             .merge(file_options(options))
             .merge(options)
          set_attributes(options)
        end

        def client
          @client ||= Aws::SQS::Client.new(user_agent_suffix: user_agent)
        end

        # Return the queue_url for a given job_queue name
        def queue_url_for(job_queue)
          job_queue = job_queue.to_sym
          raise ArgumentError, "No queue defined for #{job_queue}" unless queues.key? job_queue

          queues[job_queue.to_sym]
        end

        # @api private
        def to_s
          to_h.to_s
        end

        # @api private
        def to_h
          h = {}
          self.instance_variables.each do |v|
            v_sym = v.to_s.gsub('@', '').to_sym
            val = self.instance_variable_get(v)
            h[v_sym] = val
          end
          h
        end

        private

        # Set accessible attributes after merged options.
        def set_attributes(options)
          options.keys.each do |opt_name|
            instance_variable_set("@#{opt_name}", options[opt_name])
          end
        end

        def file_options(options = {})
          file_path = config_file_path(options)
          if file_path
            load_from_file(file_path)
          else
            {}
          end
        end

        def config_file
          file = ::Rails.root.join("config/aws_sqs_active_job/#{::Rails.env}.yml")
          file = ::Rails.root.join('config/aws_sqs_active_job.yml') unless file.exist?
          file
        end

        # Load options from YAML file
        def load_from_file(file_path)
          require "erb"
          opts = YAML.load(ERB.new(File.read(file_path)).result) || {}
          opts.deep_symbolize_keys
        end

        # @return [String] Configuration path found in environment or YAML file.
        def config_file_path(options)
          options[:config_file] || ENV["AWS_SQS_ACTIVE_JOB_CONFIG_FILE"]
        end

        def user_agent
          "ft/aws-sdk-rails-activejob/#{Aws::Rails::VERSION}"
        end
      end
    end
  end
end
