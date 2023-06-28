require "resque"
require "resque/failure/multiple"

module Bugsnag
  class Resque < ::Resque::Failure::Base

    FRAMEWORK_ATTRIBUTES = {
      :framework => "Resque"
    }

    ##
    # Callthrough to Bugsnag configuration.
    def self.configure(&block)
      add_failure_backend
      Bugsnag.configure(&block)
    end

    ##
    # Sets up the Resque failure backend.
    def self.add_failure_backend
      return if ::Resque::Failure.backend == self

      # Ensure resque is using a "Multiple" failure backend
      unless ::Resque::Failure.backend < ::Resque::Failure::Multiple
        original_backend = ::Resque::Failure.backend
        ::Resque::Failure.backend = ::Resque::Failure::Multiple
        ::Resque::Failure.backend.classes ||= []
        ::Resque::Failure.backend.classes << original_backend
      end

      # Add Bugsnag failure backend
      unless ::Resque::Failure.backend.classes.include?(self)
        ::Resque::Failure.backend.classes << self
      end
    end

    ##
    # Notifies Bugsnag of a raised exception.
    def save
      Bugsnag.notify(exception, true) do |report|
        report.severity = "error"
        report.severity_reason = {
          :type => Bugsnag::Report::UNHANDLED_EXCEPTION_MIDDLEWARE,
          :attributes => FRAMEWORK_ATTRIBUTES
        }

        metadata = payload
        class_name = metadata['class']

        # when using Active Job the payload "class" will always be the Resque
        # "JobWrapper", so we need to unwrap the actual class name
        if class_name == "ActiveJob::QueueAdapters::ResqueAdapter::JobWrapper"
          unwrapped_class_name = metadata['args'][0]['job_class'] rescue nil

          if unwrapped_class_name
            class_name = unwrapped_class_name
            metadata['wrapped'] ||= unwrapped_class_name
          end
        end

        context = "#{class_name}@#{queue}"
        report.meta_data.merge!({ context: context, payload: metadata })
        report.automatic_context = context
      end
    end
  end
end

# For backwards compatibility
Resque::Failure::Bugsnag = Bugsnag::Resque

# Auto-load the failure backend
Bugsnag::Resque.add_failure_backend

worker = Resque::Worker.new(:bugsnag_fork_check)

# If at_exit hooks are not enabled then we can't use the thread queue delivery
# method because it relies on an at_exit hook to ensure the queue is flushed
can_use_thread_queue = worker.respond_to?(:run_at_exit_hooks) && worker.run_at_exit_hooks
default_delivery_method = can_use_thread_queue ? :thread_queue : :synchronous

if worker.fork_per_job?
  Resque.after_fork do
    Bugsnag.configuration.detected_app_type = "resque"
    Bugsnag.configuration.default_delivery_method = default_delivery_method
    Bugsnag.configuration.runtime_versions["resque"] = ::Resque::VERSION
  end
else
  Resque.before_first_fork do
    Bugsnag.configuration.detected_app_type = "resque"
    Bugsnag.configuration.default_delivery_method = default_delivery_method
    Bugsnag.configuration.runtime_versions["resque"] = ::Resque::VERSION
  end
end
