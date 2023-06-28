require "json"
require "pathname"
require "bugsnag/error"
require "bugsnag/stacktrace"

module Bugsnag
  # rubocop:todo Metrics/ClassLength
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

    # The delivery method that will be used for this report
    # @see Configuration#delivery_method
    # @return [Symbol]
    attr_accessor :delivery_method

    # The list of exceptions in this report
    # @deprecated Use {#errors} instead
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
    # @deprecated Use {#metadata} instead
    # @return [Hash]
    attr_accessor :meta_data

    # The raw Exception instances for this report
    # @deprecated Use {#original_error} instead
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

    # A list of errors in this report
    # @return [Array<Error>]
    attr_reader :errors

    # The Exception instance this report was created for
    # @return [Exception]
    attr_reader :original_error

    ##
    # Initializes a new report from an exception.
    def initialize(exception, passed_configuration, auto_notify=false)
      # store the creation time for use as device.time
      @created_at = Time.now.utc.iso8601(3)

      @should_ignore = false
      @unhandled = auto_notify
      @initial_unhandled = @unhandled

      self.configuration = passed_configuration

      @original_error = exception
      self.raw_exceptions = generate_raw_exceptions(exception)
      self.exceptions = generate_exception_list
      @errors = generate_error_list

      self.api_key = configuration.api_key
      self.app_type = configuration.app_type
      self.app_version = configuration.app_version
      self.breadcrumbs = []
      self.context = configuration.context if configuration.context_set?
      self.delivery_method = configuration.delivery_method
      self.hostname = configuration.hostname
      self.runtime_versions = configuration.runtime_versions.dup
      self.meta_data = Utility::Duplicator.duplicate(configuration.metadata)
      self.release_stage = configuration.release_stage
      self.severity = auto_notify ? "error" : "warning"
      self.severity_reason = auto_notify ? {:type => UNHANDLED_EXCEPTION} : {:type => HANDLED_EXCEPTION}
      self.user = {}

      @metadata_delegate = Utility::MetadataDelegate.new
    end

    ##
    # Additional context for this report
    # @!attribute context
    # @return [String, nil]
    def context
      return @context if defined?(@context)

      @automatic_context
    end

    attr_writer :context

    ##
    # Context set automatically by Bugsnag uses this attribute, which prevents
    # it from overwriting the user-supplied context
    # @api private
    # @return [String, nil]
    attr_accessor :automatic_context

    ##
    # Add a new metadata tab to this notification.
    #
    # @param name [String, #to_s] The name of the tab to add
    # @param value [Hash, Object] The value to add to the tab. If the tab already
    #   exists, this will be merged with the existing values. If a Hash is not
    #   given, the value will be placed into the 'custom' tab
    # @return [void]
    #
    # @deprecated Use {#add_metadata} instead
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
    #
    # @deprecated Use {#clear_metadata} instead
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
          runtimeVersions: runtime_versions,
          time: @created_at
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

    # A Hash containing arbitrary metadata
    # @!attribute metadata
    # @return [Hash]
    def metadata
      @meta_data
    end

    # @param metadata [Hash]
    # @return [void]
    def metadata=(metadata)
      @meta_data = metadata
    end

    ##
    # Data from the current HTTP request. May be nil if no data has been recorded
    #
    # @return [Hash, nil]
    def request
      @meta_data[:request]
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
      @metadata_delegate.add_metadata(@meta_data, section, key_or_data, *args)
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
      @metadata_delegate.clear_metadata(@meta_data, section, *args)
    end

    ##
    # Set information about the current user
    #
    # Additional user fields can be added as metadata in a "user" section
    #
    # Setting a field to 'nil' will remove it from the user data
    #
    # @param id [String, nil]
    # @param email [String, nil]
    # @param name [String, nil]
    # @return [void]
    def set_user(id = nil, email = nil, name = nil)
      new_user = { id: id, email: email, name: name }
      new_user.reject! { |key, value| value.nil? }

      @user = new_user
    end

    def unhandled=(new_unhandled)
      # fix the handled/unhandled counts in the current session
      update_handled_counts(new_unhandled, @unhandled)

      @unhandled = new_unhandled
    end

    ##
    # Returns true if the unhandled flag has been changed from its initial value
    #
    # @api private
    # @return [Boolean]
    def unhandled_overridden?
      @unhandled != @initial_unhandled
    end

    private

    def update_handled_counts(is_unhandled, was_unhandled)
      # do nothing if there is no session to update
      return if @session.nil?

      # increment the counts for the current unhandled value
      if is_unhandled
        @session[:events][:unhandled] += 1
      else
        @session[:events][:handled] += 1
      end

      # decrement the counts for the previous unhandled value
      if was_unhandled
        @session[:events][:unhandled] -= 1
      else
        @session[:events][:handled] -= 1
      end
    end

    def generate_exception_list
      raw_exceptions.map do |exception|
        {
          errorClass: error_class(exception),
          message: exception.message,
          stacktrace: Stacktrace.process(exception.backtrace, configuration)
        }
      end
    end

    def generate_error_list
      exceptions.map do |exception|
        Error.new(exception[:errorClass], exception[:message], exception[:stacktrace])
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
  # rubocop:enable Metrics/ClassLength
end
