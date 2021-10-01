require "json"
require "pathname"
require "bugsnag/stacktrace"

module Bugsnag
  class Report
    NOTIFIER_NAME = "Ruby Bugsnag Notifier"
    NOTIFIER_VERSION = Bugsnag::VERSION
    NOTIFIER_URL = "https://www.bugsnag.com"

    UNHANDLED_EXCEPTION = "unhandledException"
    UNHANDLED_EXCEPTION_MIDDLEWARE = "unhandledExceptionMiddleware"
    ERROR_CLASS = "errorClass"
    HANDLED_EXCEPTION = "handledException"
    USER_SPECIFIED_SEVERITY = "userSpecifiedSeverity"
    USER_CALLBACK_SET_SEVERITY = "userCallbackSetSeverity"

    MAX_EXCEPTIONS_TO_UNWRAP = 5

    CURRENT_PAYLOAD_VERSION = "4.0"

    # Whether this report is for a handled or unhandled error
    # @return [Boolean]
    attr_reader :unhandled

    # Your Integration API Key
    # @see Configuration#api_key
    # @return [String, nil]
    attr_accessor :api_key

    # The type of application executing the current code
    # @see Configuration#app_type
    # @return [String, nil]
    attr_accessor :app_type

    # The current version of your application
    # @return [String, nil]
    attr_accessor :app_version

    # The list of breadcrumbs attached to this report
    # @return [Array<Breadcrumb>]
    attr_accessor :breadcrumbs

    # @api private
    # @return [Configuration]
    attr_accessor :configuration

    # Additional context for this report
    # @return [String, nil]
    attr_accessor :context

    # The delivery method that will be used for this report
    # @see Configuration#delivery_method
    # @return [Symbol]
    attr_accessor :delivery_method

    # The list of exceptions in this report
    # @return [Array<Hash>]
    attr_accessor :exceptions

    # @see Configuration#hostname
    # @return [String]
    attr_accessor :hostname

    # @api private
    # @see Configuration#runtime_versions
    # @return [Hash{String => String}]
    attr_accessor :runtime_versions

    # All errors with the same grouping hash will be grouped in the Bugsnag app
    # @return [String]
    attr_accessor :grouping_hash

    # Arbitrary metadata attached to this report
    # @return [Hash]
    attr_accessor :meta_data

    # The raw Exception instances for this report
    # @see #exceptions
    # @return [Array<Exception>]
    attr_accessor :raw_exceptions

    # The current stage of the release process, e.g. 'development', production'
    # @see Configuration#release_stage
    # @return [String, nil]
    attr_accessor :release_stage

    # The session that active when this report was generated
    # @see SessionTracker#get_current_session
    # @return [Hash]
    attr_accessor :session

    # The severity of this report, e.g. 'error', 'warning'
    # @return [String]
    attr_accessor :severity

    # @api private
    # @return [Hash]
    attr_accessor :severity_reason

    # The current user when this report was generated
    # @return [Hash]
    attr_accessor :user

    ##
    # Initializes a new report from an exception.
    def initialize(exception, passed_configuration, auto_notify=false)
      @should_ignore = false
      @unhandled = auto_notify

      self.configuration = passed_configuration

      self.raw_exceptions = generate_raw_exceptions(exception)
      self.exceptions = generate_exception_list

      self.api_key = configuration.api_key
      self.app_type = configuration.app_type
      self.app_version = configuration.app_version
      self.breadcrumbs = []
      self.delivery_method = configuration.delivery_method
      self.hostname = configuration.hostname
      self.runtime_versions = configuration.runtime_versions.dup
      self.meta_data = {}
      self.release_stage = configuration.release_stage
      self.severity = auto_notify ? "error" : "warning"
      self.severity_reason = auto_notify ? {:type => UNHANDLED_EXCEPTION} : {:type => HANDLED_EXCEPTION}
      self.user = {}
    end

    ##
    # Add a new metadata tab to this notification.
    #
    # @param name [String, #to_s] The name of the tab to add
    # @param value [Hash, Object] The value to add to the tab. If the tab already
    #   exists, this will be merged with the existing values. If a Hash is not
    #   given, the value will be placed into the 'custom' tab
    # @return [void]
    def add_tab(name, value)
      return if name.nil?

      if value.is_a? Hash
        meta_data[name] ||= {}
        meta_data[name].merge! value
      else
        meta_data["custom"] = {} unless meta_data["custom"]

        meta_data["custom"][name.to_s] = value
      end
    end

    ##
    # Removes a metadata tab from this notification.
    #
    # @param name [String]
    # @return [void]
    def remove_tab(name)
      return if name.nil?

      meta_data.delete(name)
    end

    ##
    # Builds and returns the exception payload for this notification.
    #
    # @return [Hash]
    def as_json
      # Build the payload's exception event
      payload_event = {
        app: {
          version: app_version,
          releaseStage: release_stage,
          type: app_type
        },
        breadcrumbs: breadcrumbs.map(&:to_h),
        context: context,
        device: {
          hostname: hostname,
          runtimeVersions: runtime_versions
        },
        exceptions: exceptions,
        groupingHash: grouping_hash,
        metaData: meta_data,
        session: session,
        severity: severity,
        severityReason: severity_reason,
        unhandled: @unhandled,
        user: user
      }

      payload_event.reject! {|k, v| v.nil? }

      # return the payload hash
      {
        :apiKey => api_key,
        :notifier => {
          :name => NOTIFIER_NAME,
          :version => NOTIFIER_VERSION,
          :url => NOTIFIER_URL
        },
        :events => [payload_event]
      }
    end

    ##
    # Returns the headers required for the notification.
    #
    # @return [Hash{String => String}]
    def headers
      {
        "Bugsnag-Api-Key" => api_key,
        "Bugsnag-Payload-Version" => CURRENT_PAYLOAD_VERSION,
        "Bugsnag-Sent-At" => Time.now.utc.iso8601(3)
      }
    end

    ##
    # Whether this report should be ignored and not sent.
    #
    # @return [Boolean]
    def ignore?
      @should_ignore
    end

    ##
    # Data set on the configuration to be attached to every error notification.
    #
    # @return [Hash]
    def request_data
      configuration.request_data
    end

    ##
    # Tells the client this report should not be sent.
    #
    # @return [void]
    def ignore!
      @should_ignore = true
    end

    ##
    # Generates a summary to be attached as a breadcrumb
    #
    # @return [Hash] a Hash containing the report's error class, error message, and severity
    def summary
      # Guard against the exceptions array being removed/changed or emptied here
      if exceptions.respond_to?(:first) && exceptions.first
        {
          :error_class => exceptions.first[:errorClass],
          :message => exceptions.first[:message],
          :severity => severity
        }
      else
        {
          :error_class => "Unknown",
          :severity => severity
        }
      end
    end

    private

    def generate_exception_list
      raw_exceptions.map do |exception|
        {
          errorClass: error_class(exception),
          message: exception.message,
          stacktrace: Stacktrace.process(exception.backtrace, configuration)
        }
      end
    end

    def error_class(exception)
      # The "Class" check is for some strange exceptions like Timeout::Error
      # which throw the error class instead of an instance
      (exception.is_a? Class) ? exception.name : exception.class.name
    end

    def generate_raw_exceptions(exception)
      exceptions = []

      ex = exception
      while ex != nil && !exceptions.include?(ex) && exceptions.length < MAX_EXCEPTIONS_TO_UNWRAP

        unless ex.is_a? Exception
          if ex.respond_to?(:to_exception)
            ex = ex.to_exception
          elsif ex.respond_to?(:exception)
            ex = ex.exception
          end
        end

        unless ex.is_a?(Exception) || (defined?(Java::JavaLang::Throwable) && ex.is_a?(Java::JavaLang::Throwable))
          configuration.warn("Converting non-Exception to RuntimeError: #{ex.inspect}")
          ex = RuntimeError.new(ex.to_s)
          ex.set_backtrace caller
        end

        exceptions << ex

        if ex.respond_to?(:cause) && ex.cause
          ex = ex.cause
        elsif ex.respond_to?(:continued_exception) && ex.continued_exception
          ex = ex.continued_exception
        elsif ex.respond_to?(:original_exception) && ex.original_exception
          ex = ex.original_exception
        else
          ex = nil
        end
      end

      exceptions
    end
  end
end
