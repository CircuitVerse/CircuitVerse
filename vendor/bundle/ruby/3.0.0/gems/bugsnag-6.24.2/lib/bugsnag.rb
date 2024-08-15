require "rubygems"
require "thread"

require "bugsnag/version"
require "bugsnag/configuration"
require "bugsnag/meta_data"
require "bugsnag/report"
require "bugsnag/event"
require "bugsnag/cleaner"
require "bugsnag/helpers"
require "bugsnag/session_tracker"

require "bugsnag/delivery"
require "bugsnag/delivery/synchronous"
require "bugsnag/delivery/thread_queue"

# Rack is not bundled with the other integrations
# as it doesn't auto-configure when loaded
require "bugsnag/integrations/rack"

require "bugsnag/middleware/rack_request"
require "bugsnag/middleware/warden_user"
require "bugsnag/middleware/clearance_user"
require "bugsnag/middleware/callbacks"
require "bugsnag/middleware/rails3_request"
require "bugsnag/middleware/sidekiq"
require "bugsnag/middleware/mailman"
require "bugsnag/middleware/rake"
require "bugsnag/middleware/classify_error"
require "bugsnag/middleware/delayed_job"

require "bugsnag/breadcrumb_type"
require "bugsnag/breadcrumbs/validator"
require "bugsnag/breadcrumbs/breadcrumb"
require "bugsnag/breadcrumbs/breadcrumbs"

require "bugsnag/utility/duplicator"
require "bugsnag/utility/metadata_delegate"

# rubocop:todo Metrics/ModuleLength
module Bugsnag
  LOCK = Mutex.new
  INTEGRATIONS = [:resque, :sidekiq, :mailman, :delayed_job, :shoryuken, :que, :mongo]

  NIL_EXCEPTION_DESCRIPTION = "'nil' was notified as an exception"

  class << self
    ##
    # Configure the Bugsnag notifier application-wide settings.
    #
    # Yields a {Configuration} object to use to set application settings.
    #
    # @yieldparam configuration [Configuration]
    # @return [void]
    def configure(validate_api_key=true)
      yield(configuration) if block_given?

      # Create the session tracker if sessions are enabled to avoid the overhead
      # of creating it on the first request. We skip this if we're not validating
      # the API key as we use this internally before the user's configure block
      # has run, so we don't know if sessions are enabled yet.
      session_tracker if validate_api_key && configuration.auto_capture_sessions

      check_key_valid if validate_api_key
      check_endpoint_setup

      register_at_exit
    end

    ##
    # Explicitly notify of an exception.
    #
    # Optionally accepts a block to append metadata to the yielded report.
    def notify(exception, auto_notify=false, &block)
      unless auto_notify.is_a? TrueClass or auto_notify.is_a? FalseClass
        configuration.warn("Adding metadata/severity using a hash is no longer supported, please use block syntax instead")
        auto_notify = false
      end

      return unless should_deliver_notification?(exception, auto_notify)

      exception = NIL_EXCEPTION_DESCRIPTION if exception.nil?

      report = Report.new(exception, configuration, auto_notify)

      # If this is an auto_notify we yield the block before the any middleware is run
      begin
        yield(report) if block_given? && auto_notify
      rescue StandardError => e
        configuration.warn("Error in internal notify block: #{e}")
        configuration.warn("Error in internal notify block stacktrace: #{e.backtrace.inspect}")
      end

      if report.ignore?
        configuration.debug("Not notifying #{report.exceptions.last[:errorClass]} due to ignore being signified in auto_notify block")
        return
      end

      # Run internal middleware
      configuration.internal_middleware.run(report)
      if report.ignore?
        configuration.debug("Not notifying #{report.exceptions.last[:errorClass]} due to ignore being signified in internal middlewares")
        return
      end

      # Store before_middleware severity reason for future reference
      initial_severity = report.severity
      initial_reason = report.severity_reason

      # Run users middleware
      configuration.middleware.run(report) do
        if report.ignore?
          configuration.debug("Not notifying #{report.exceptions.last[:errorClass]} due to ignore being signified in user provided middleware")
          return
        end

        # If this is not an auto_notify then the block was provided by the user. This should be the last
        # block that is run as it is the users "most specific" block.
        begin
          yield(report) if block_given? && !auto_notify
        rescue StandardError => e
          configuration.warn("Error in notify block: #{e}")
          configuration.warn("Error in notify block stacktrace: #{e.backtrace.inspect}")
        end

        if report.ignore?
          configuration.debug("Not notifying #{report.exceptions.last[:errorClass]} due to ignore being signified in user provided block")
          return
        end

        # Test whether severity has been changed and ensure severity_reason is consistant in auto_notify case
        if report.severity != initial_severity
          report.severity_reason = {
            :type => Report::USER_CALLBACK_SET_SEVERITY
          }
        else
          report.severity_reason = initial_reason
        end

        if report.unhandled_overridden?
          # let the dashboard know that the unhandled flag was overridden
          report.severity_reason[:unhandledOverridden] = true
        end

        deliver_notification(report)
      end
    end

    ##
    # Registers an at_exit function to automatically catch errors on exit.
    #
    # @return [void]
    def register_at_exit
      return if at_exit_handler_installed?
      @exit_handler_added = true
      at_exit do
        if $!
          exception = unwrap_bundler_exception($!)

          Bugsnag.notify(exception, true) do |report|
            report.severity = 'error'
            report.severity_reason = {
              :type => Bugsnag::Report::UNHANDLED_EXCEPTION
            }
          end
        end
      end
    end

    ##
    # Checks if an at_exit handler has been added.
    #
    # The {Bugsnag#configure} method will add this automatically, but it can be
    # added manually using {Bugsnag#register_at_exit}.
    #
    # @return [Boolean]
    def at_exit_handler_installed?
      @exit_handler_added ||= false
    end

    ##
    # Returns the client's Configuration object, or creates one if not yet created.
    #
    # @return [Configuration]
    def configuration
      @configuration = nil unless defined?(@configuration)
      @configuration || LOCK.synchronize { @configuration ||= Bugsnag::Configuration.new }
    end

    ##
    # Returns the client's SessionTracker object, or creates one if not yet created.
    #
    # @return [SessionTracker]
    def session_tracker
      @session_tracker = nil unless defined?(@session_tracker)
      @session_tracker || LOCK.synchronize { @session_tracker ||= Bugsnag::SessionTracker.new}
    end

    ##
    # Starts a new session, which allows Bugsnag to track error rates across
    # releases
    #
    # @return [void]
    def start_session
      session_tracker.start_session
    end

    ##
    # Stop any events being attributed to the current session until it is
    # resumed or a new session is started
    #
    # @see resume_session
    #
    # @return [void]
    def pause_session
      session_tracker.pause_session
    end

    ##
    # Resume the current session if it was previously paused. If there is no
    # current session, a new session will be started
    #
    # @see pause_session
    #
    # @return [Boolean] true if a paused session was resumed
    def resume_session
      session_tracker.resume_session
    end

    ##
    # Allow access to "before notify" callbacks as an array.
    #
    # These callbacks will be called whenever an error notification is being made.
    #
    # @deprecated Use {Bugsnag#add_on_error} instead
    def before_notify_callbacks
      Bugsnag.configuration.request_data[:before_callbacks] ||= []
    end

    ##
    # Attempts to load all integrations through auto-discovery.
    #
    # @return [void]
    def load_integrations
      require "bugsnag/integrations/railtie" if defined?(Rails::Railtie)
      INTEGRATIONS.each do |integration|
        begin
          require "bugsnag/integrations/#{integration}"
        rescue LoadError
        end
      end
    end

    ##
    # Load a specific integration.
    #
    # @param integration [Symbol] One of the integrations in {INTEGRATIONS}
    # @return [void]
    def load_integration(integration)
      integration = :railtie if integration == :rails
      if INTEGRATIONS.include?(integration) || integration == :railtie
        require "bugsnag/integrations/#{integration}"
      else
        configuration.debug("Integration #{integration} is not currently supported")
      end
    end

    ##
    # Leave a breadcrumb to be attached to subsequent reports
    #
    # @param name [String] the main breadcrumb name/message
    # @param meta_data [Hash] String, Numeric, or Boolean meta data to attach
    # @param type [String] the breadcrumb type, see {Bugsnag::BreadcrumbType}
    # @param auto [Symbol] set to :auto if the breadcrumb is automatically created
    # @return [void]
    def leave_breadcrumb(name, meta_data={}, type=Bugsnag::Breadcrumbs::MANUAL_BREADCRUMB_TYPE, auto=:manual)
      breadcrumb = Bugsnag::Breadcrumbs::Breadcrumb.new(name, type, meta_data, auto)
      validator = Bugsnag::Breadcrumbs::Validator.new(configuration)

      # Initial validation
      validator.validate(breadcrumb)

      # Skip if it's already invalid
      return if breadcrumb.ignore?

      # Run before_breadcrumb_callbacks
      configuration.before_breadcrumb_callbacks.each do |c|
        c.arity > 0 ? c.call(breadcrumb) : c.call
        break if breadcrumb.ignore?
      end

      # Return early if ignored
      return if breadcrumb.ignore?

      # Run on_breadcrumb callbacks
      configuration.on_breadcrumb_callbacks.call(breadcrumb)
      return if breadcrumb.ignore?

      # Validate again in case of callback alteration
      validator.validate(breadcrumb)

      # Add to breadcrumbs buffer if still valid
      configuration.breadcrumbs << breadcrumb unless breadcrumb.ignore?
    end

    ##
    # Add the given callback to the list of on_error callbacks
    #
    # The on_error callbacks will be called when an error is captured or reported
    # and are passed a {Bugsnag::Report} object
    #
    # Returning false from an on_error callback will cause the error to be ignored
    # and will prevent any remaining callbacks from being called
    #
    # @param callback [Proc, Method, #call]
    # @return [void]
    def add_on_error(callback)
      configuration.add_on_error(callback)
    end

    ##
    # Remove the given callback from the list of on_error callbacks
    #
    # Note that this must be the same Proc instance that was passed to
    # {Bugsnag#add_on_error}, otherwise it will not be removed
    #
    # @param callback [Proc]
    # @return [void]
    def remove_on_error(callback)
      configuration.remove_on_error(callback)
    end

    ##
    # Add the given callback to the list of on_breadcrumb callbacks
    #
    # The on_breadcrumb callbacks will be called when a breadcrumb is left and
    # are passed the {Breadcrumbs::Breadcrumb Breadcrumb} object
    #
    # Returning false from an on_breadcrumb callback will cause the breadcrumb
    # to be ignored and will prevent any remaining callbacks from being called
    #
    # @param callback [Proc, Method, #call]
    # @return [void]
    def add_on_breadcrumb(callback)
      configuration.add_on_breadcrumb(callback)
    end

    ##
    # Remove the given callback from the list of on_breadcrumb callbacks
    #
    # Note that this must be the same instance that was passed to
    # {add_on_breadcrumb}, otherwise it will not be removed
    #
    # @param callback [Proc, Method, #call]
    # @return [void]
    def remove_on_breadcrumb(callback)
      configuration.remove_on_breadcrumb(callback)
    end

    ##
    # Returns the current list of breadcrumbs
    #
    # This is a per-thread circular buffer, containing at most 'max_breadcrumbs'
    # breadcrumbs
    #
    # @return [Bugsnag::Utility::CircularBuffer]
    def breadcrumbs
      configuration.breadcrumbs
    end

    ##
    # Returns the client's Cleaner object, or creates one if not yet created.
    #
    # @api private
    #
    # @return [Cleaner]
    def cleaner
      @cleaner = nil unless defined?(@cleaner)
      @cleaner || LOCK.synchronize do
        @cleaner ||= Bugsnag::Cleaner.new(configuration)
      end
    end

    ##
    # Global metadata added to every event
    #
    # @return [Hash]
    def metadata
      configuration.metadata
    end

    ##
    # Add values to metadata
    #
    # @overload add_metadata(section, data)
    #   Merges data into the given section of metadata
    #   @param section [String, Symbol]
    #   @param data [Hash]
    #
    # @overload add_metadata(section, key, value)
    #   Sets key to value in the given section of metadata. If the value is nil
    #   the key will be deleted
    #   @param section [String, Symbol]
    #   @param key [String, Symbol]
    #   @param value
    #
    # @return [void]
    def add_metadata(section, key_or_data, *args)
      configuration.add_metadata(section, key_or_data, *args)
    end

    ##
    # Clear values from metadata
    #
    # @overload clear_metadata(section)
    #   Clears the given section of metadata
    #   @param section [String, Symbol]
    #
    # @overload clear_metadata(section, key)
    #   Clears the key in the given section of metadata
    #   @param section [String, Symbol]
    #   @param key [String, Symbol]
    #
    # @return [void]
    def clear_metadata(section, *args)
      configuration.clear_metadata(section, *args)
    end

    private

    def should_deliver_notification?(exception, auto_notify)
      return false unless configuration.enable_events

      reason = abort_reason(exception, auto_notify)
      configuration.debug(reason) unless reason.nil?
      reason.nil?
    end

    def abort_reason(exception, auto_notify)
      if !configuration.auto_notify && auto_notify
        "Not notifying because auto_notify is disabled"
      elsif !configuration.valid_api_key?
        "Not notifying due to an invalid api_key"
      elsif !configuration.should_notify_release_stage?
        "Not notifying due to notify_release_stages :#{configuration.notify_release_stages.inspect}"
      elsif exception.respond_to?(:skip_bugsnag) && exception.skip_bugsnag
        "Not notifying due to skip_bugsnag flag"
      end
    end

    ##
    # Deliver the notification to Bugsnag
    #
    # @param report [Report]
    # @return void
    def deliver_notification(report)
      configuration.info("Notifying #{configuration.notify_endpoint} of #{report.exceptions.last[:errorClass]}")

      options = { headers: report.headers }

      delivery_method = Bugsnag::Delivery[configuration.delivery_method]

      if delivery_method.respond_to?(:serialize_and_deliver)
        delivery_method.serialize_and_deliver(
          configuration.notify_endpoint,
          proc { report_to_json(report) },
          configuration,
          options
        )
      else
        delivery_method.deliver(
          configuration.notify_endpoint,
          report_to_json(report),
          configuration,
          options
        )
      end

      leave_breadcrumb(
        report.summary[:error_class],
        report.summary,
        Bugsnag::Breadcrumbs::ERROR_BREADCRUMB_TYPE,
        :auto
      )
    end

    # Check if the API key is valid and warn (once) if it is not
    def check_key_valid
      @key_warning = false unless defined?(@key_warning)
      if !configuration.valid_api_key? && !@key_warning
        configuration.warn("No valid API key has been set, notifications will not be sent")
        @key_warning = true
      end
    end

    ##
    # Verifies the current endpoint setup
    #
    # If only a notify_endpoint has been set, session tracking will be disabled
    # If only a session_endpoint has been set, and ArgumentError will be raised
    def check_endpoint_setup
      notify_set = configuration.notify_endpoint && configuration.notify_endpoint != Bugsnag::Configuration::DEFAULT_NOTIFY_ENDPOINT
      session_set = configuration.session_endpoint && configuration.session_endpoint != Bugsnag::Configuration::DEFAULT_SESSION_ENDPOINT
      if notify_set && !session_set
        configuration.warn("The session endpoint has not been set, all further session capturing will be disabled")
        configuration.disable_sessions
      elsif !notify_set && session_set
        raise ArgumentError, "The session endpoint cannot be modified without the notify endpoint"
      end
    end

    ##
    # Convert the Report object to JSON
    #
    # We ensure the report is safe to send by removing recursion, fixing
    # encoding errors and redacting metadata according to "meta_data_filters"
    #
    # @param report [Report]
    # @return [String]
    def report_to_json(report)
      cleaned = cleaner.clean_object(report.as_json)
      trimmed = Bugsnag::Helpers.trim_if_needed(cleaned)

      ::JSON.dump(trimmed)
    end

    ##
    # When running a script with 'bundle exec', uncaught exceptions will be
    # converted to "friendly errors" which has the side effect of wrapping them
    # in a SystemExit
    #
    # By default we ignore SystemExit, so need to unwrap the original exception
    # in order to avoid ignoring real errors
    #
    # @param exception [Exception]
    # @return [Exception]
    def unwrap_bundler_exception(exception)
      running_in_bundler = ENV.include?('BUNDLE_BIN_PATH')

      # See if this exception came from Bundler's 'with_friendly_errors' method
      return exception unless running_in_bundler
      return exception unless exception.is_a?(SystemExit)
      return exception unless exception.respond_to?(:cause)
      return exception unless exception.backtrace.first.include?('/bundler/friendly_errors.rb')
      return exception if exception.cause.nil?

      unwrapped = exception.cause

      # We may need to unwrap another level if the exception came from running
      # an executable file directly (i.e. 'bundle exec <file>'). In this case
      # there can be a SystemExit from 'with_friendly_errors' _and_ a SystemExit
      # from 'kernel_load'
      return unwrapped unless unwrapped.is_a?(SystemExit)
      return unwrapped unless unwrapped.backtrace.first.include?('/bundler/cli/exec.rb')
      return unwrapped if unwrapped.cause.nil?

      unwrapped.cause
    end
  end
end
# rubocop:enable Metrics/ModuleLength

Bugsnag.load_integrations unless ENV["BUGSNAG_DISABLE_AUTOCONFIGURE"]
