require "set"
require "socket"
require "logger"
require "bugsnag/middleware_stack"
require "bugsnag/middleware/callbacks"
require "bugsnag/middleware/discard_error_class"
require "bugsnag/middleware/exception_meta_data"
require "bugsnag/middleware/ignore_error_class"
require "bugsnag/middleware/suggestion_data"
require "bugsnag/middleware/classify_error"
require "bugsnag/middleware/session_data"
require "bugsnag/middleware/breadcrumbs"
require "bugsnag/utility/circular_buffer"
require "bugsnag/breadcrumbs/breadcrumbs"

module Bugsnag
  class Configuration
    # Your Integration API Key
    # @return [String, nil]
    attr_accessor :api_key

    # The current stage of the release process, e.g. 'development', production'
    # @return [String, nil]
    attr_accessor :release_stage

    # A list of which release stages should cause notifications to be sent
    # @return [Array<String>, nil]
    attr_accessor :notify_release_stages

    # Whether notifications should automatically be sent
    # @return [Boolean]
    attr_accessor :auto_notify

    # @return [String, nil]
    attr_accessor :ca_file

    # Whether to automatically attach the Rack environment to notifications
    # @return [Boolean]
    attr_accessor :send_environment

    # Whether code snippets from the exception stacktrace should be sent with notifications
    # @return [Boolean]
    attr_accessor :send_code

    # Any stacktrace lines that match this path will be marked as 'in project'
    # @return [String, nil]
    attr_accessor :project_root

    # The current version of your application
    # @return [String, nil]
    attr_accessor :app_version

    # A list of keys that should be filtered out from the report and breadcrumb
    # metadata before sending them to Bugsnag
    # @return [Set<String, Regexp>]
    attr_accessor :meta_data_filters

    # The logger to use for Bugsnag log messages
    # @return [Logger]
    attr_accessor :logger

    # The middleware stack that will run on every notification
    # @return [MiddlewareStack]
    attr_accessor :middleware

    # @api private
    # @return [MiddlewareStack]
    attr_accessor :internal_middleware

    # The host address of the HTTP proxy that should be used when making requests
    # @see parse_proxy
    # @return [String, nil]
    attr_accessor :proxy_host

    # The port number of the HTTP proxy that should be used when making requests
    # @see parse_proxy
    # @return [Integer, nil]
    attr_accessor :proxy_port

    # The user that should be used when making requests via a HTTP proxy
    # @see parse_proxy
    # @return [String, nil]
    attr_accessor :proxy_user

    # The password for the user that should be used when making requests via a HTTP proxy
    # @see parse_proxy
    # @return [String, nil]
    attr_accessor :proxy_password

    # The HTTP request timeout, defaults to 15 seconds
    # @return [Integer]
    attr_accessor :timeout

    # The name or descriptor of the Ruby server host
    # @return [String]
    attr_accessor :hostname

    # @api private
    # @return [Hash{String => String}]
    attr_accessor :runtime_versions

    # Exception classes that will be discarded and not sent to Bugsnag
    # @return [Set<String, Regexp>]
    attr_accessor :discard_classes

    # Whether Bugsnag should automatically record sessions
    # @return [Boolean]
    attr_accessor :auto_capture_sessions

    # @deprecated Use {#discard_classes} instead
    # @return [Set<Class, Proc>]
    attr_accessor :ignore_classes

    # The URL error notifications will be delivered to
    # @return [String]
    attr_reader :notify_endpoint
    alias :endpoint :notify_endpoint

    # The URL session notifications will be delivered to
    # @return [String]
    attr_reader :session_endpoint

    # Whether sessions will be delivered
    # @return [Boolean]
    attr_reader :enable_sessions

    # A list of strings indicating allowable automatic breadcrumb types
    # @see Bugsnag::Breadcrumbs::VALID_BREADCRUMB_TYPES
    # @return [Array<String>]
    attr_accessor :enabled_automatic_breadcrumb_types

    # Callables to be run before a breadcrumb is logged
    # @return [Array<#call>]
    attr_accessor :before_breadcrumb_callbacks

    # The maximum allowable amount of breadcrumbs per thread
    # @return [Integer]
    attr_reader :max_breadcrumbs

    #
    # @return [Regexp]
    attr_accessor :vendor_path

    # @api private
    # @return [Array<String>]
    attr_reader :scopes_to_filter

    API_KEY_REGEX = /[0-9a-f]{32}/i
    THREAD_LOCAL_NAME = "bugsnag_req_data"

    DEFAULT_NOTIFY_ENDPOINT = "https://notify.bugsnag.com"
    DEFAULT_SESSION_ENDPOINT = "https://sessions.bugsnag.com"
    DEFAULT_ENDPOINT = DEFAULT_NOTIFY_ENDPOINT

    DEFAULT_META_DATA_FILTERS = [
      /authorization/i,
      /cookie/i,
      /password/i,
      /secret/i,
      /warden\.user\.([^.]+)\.key/,
      "rack.request.form_vars"
    ].freeze

    DEFAULT_MAX_BREADCRUMBS = 25

    # Path to vendored code. Used to mark file paths as out of project.
    DEFAULT_VENDOR_PATH = %r{^(vendor/|\.bundle/)}

    # @api private
    DEFAULT_SCOPES_TO_FILTER = ['events.metaData', 'events.breadcrumbs.metaData'].freeze

    alias :track_sessions :auto_capture_sessions
    alias :track_sessions= :auto_capture_sessions=

    def initialize
      @mutex = Mutex.new

      # Set up the defaults
      self.auto_notify = true
      self.send_environment = false
      self.send_code = true
      self.meta_data_filters = Set.new(DEFAULT_META_DATA_FILTERS)
      self.scopes_to_filter = DEFAULT_SCOPES_TO_FILTER
      self.hostname = default_hostname
      self.runtime_versions = {}
      self.runtime_versions["ruby"] = RUBY_VERSION
      self.runtime_versions["jruby"] = JRUBY_VERSION if defined?(JRUBY_VERSION)
      self.timeout = 15
      self.release_stage = ENV['BUGSNAG_RELEASE_STAGE']
      self.notify_release_stages = nil
      self.auto_capture_sessions = true

      # All valid breadcrumb types should be allowable initially
      self.enabled_automatic_breadcrumb_types = Bugsnag::Breadcrumbs::VALID_BREADCRUMB_TYPES.dup
      self.before_breadcrumb_callbacks = []

      # Store max_breadcrumbs here instead of outputting breadcrumbs.max_items
      # to avoid infinite recursion when creating breadcrumb buffer
      @max_breadcrumbs = DEFAULT_MAX_BREADCRUMBS

      # These are set exclusively using the "set_endpoints" method
      @notify_endpoint = DEFAULT_NOTIFY_ENDPOINT
      @session_endpoint = DEFAULT_SESSION_ENDPOINT
      @enable_sessions = true

      # SystemExit and SignalException are common Exception types seen with
      # successful exits and are not automatically reported to Bugsnag
      # TODO move these defaults into `discard_classes` when `ignore_classes`
      #      is removed
      self.ignore_classes = Set.new([SystemExit, SignalException])
      self.discard_classes = Set.new([])

      # Read the API key from the environment
      self.api_key = ENV["BUGSNAG_API_KEY"]

      # Read NET::HTTP proxy environment variables
      if (proxy_uri = ENV["https_proxy"] || ENV['http_proxy'])
        parse_proxy(proxy_uri)
      end

      # Set up vendor_path regex to mark stacktrace file paths as out of project.
      # Stacktrace lines that matches regex will be marked as "out of project"
      # will only appear in the full trace.
      self.vendor_path = DEFAULT_VENDOR_PATH

      # Set up logging
      self.logger = Logger.new(STDOUT)
      self.logger.level = Logger::INFO
      self.logger.formatter = proc do |severity, datetime, progname, msg|
        "** #{progname} #{datetime}: #{msg}\n"
      end

      # Configure the bugsnag middleware stack
      self.internal_middleware = Bugsnag::MiddlewareStack.new
      self.internal_middleware.use Bugsnag::Middleware::ExceptionMetaData
      self.internal_middleware.use Bugsnag::Middleware::DiscardErrorClass
      self.internal_middleware.use Bugsnag::Middleware::IgnoreErrorClass
      self.internal_middleware.use Bugsnag::Middleware::SuggestionData
      self.internal_middleware.use Bugsnag::Middleware::ClassifyError
      self.internal_middleware.use Bugsnag::Middleware::SessionData
      self.internal_middleware.use Bugsnag::Middleware::Breadcrumbs

      self.middleware = Bugsnag::MiddlewareStack.new
      self.middleware.use Bugsnag::Middleware::Callbacks
    end

    ##
    # Gets the delivery_method that Bugsnag will use to communicate with the
    # notification endpoint.
    #
    # @return [Symbol]
    def delivery_method
      @delivery_method || @default_delivery_method || :thread_queue
    end

    ##
    # Sets the delivery_method that Bugsnag will use to communicate with the
    # notification endpoint.
    #
    # The default delivery methods are ':thread_queue' and ':synchronous'.
    #
    # @param delivery_method [Symbol]
    # @return [void]
    def delivery_method=(delivery_method)
      @delivery_method = delivery_method
    end

    ##
    # Used to set a new default delivery method that will be used if one is not
    # set with #delivery_method.
    #
    # @api private
    #
    # @param delivery_method [Symbol]
    # @return [void]
    def default_delivery_method=(delivery_method)
      @default_delivery_method = delivery_method
    end

    ##
    # Get the type of application executing the current code
    #
    # This is usually used to represent if you are running in a Rails server,
    # Sidekiq job, Rake task etc... Bugsnag will automatically detect most
    # application types for you
    #
    # @return [String, nil]
    def app_type
      @app_type || @detected_app_type
    end

    ##
    # Set the type of application executing the current code
    #
    # If an app_type is set, this will be used instead of the automatically
    # detected app_type that Bugsnag would otherwise use
    #
    # @param app_type [String]
    # @return [void]
    def app_type=(app_type)
      @app_type = app_type
    end

    ##
    # Get the detected app_type, which is used when one isn't set explicitly
    #
    # @api private
    #
    # @return [String, nil]
    def detected_app_type
      @detected_app_type
    end

    ##
    # Set the detected app_type, which is used when one isn't set explicitly
    #
    # This allows Bugsnag's integrations to say 'this is a Rails app' while
    # allowing the user to overwrite this if they wish
    #
    # @api private
    #
    # @param app_type [String]
    # @return [void]
    def detected_app_type=(app_type)
      @detected_app_type = app_type
    end

    ##
    # Indicates whether the notifier should send a notification based on the
    # configured release stage.
    #
    # @return [Boolean]
    def should_notify_release_stage?
      @release_stage.nil? || @notify_release_stages.nil? || @notify_release_stages.include?(@release_stage)
    end

    ##
    # Tests whether the configured API key is valid.
    #
    # @return [Boolean]
    def valid_api_key?
      !api_key.nil? && api_key =~ API_KEY_REGEX
    end

    ##
    # Returns the array of data that will be automatically attached to every
    # error notification.
    #
    # @return [Hash]
    def request_data
      Thread.current[THREAD_LOCAL_NAME] ||= {}
    end

    ##
    # Sets an entry in the array of data attached to every error notification.
    #
    # @param key [String, #to_s]
    # @param value [Object]
    # @return [void]
    def set_request_data(key, value)
      self.request_data[key] = value
    end

    ##
    # Unsets an entry in the array of data attached to every error notification.
    #
    # @param (see set_request_data)
    # @return [void]
    def unset_request_data(key, value)
      self.request_data.delete(key)
    end

    ##
    # Clears the array of data attached to every error notification.
    #
    # @return [void]
    def clear_request_data
      Thread.current[THREAD_LOCAL_NAME] = nil
    end

    ##
    # Logs an info level message
    #
    # @param message [String, #to_s] The message to log
    def info(message)
      logger.info(PROG_NAME) { message }
    end

    ##
    # Logs a warning level message
    #
    # @param (see info)
    def warn(message)
      logger.warn(PROG_NAME) { message }
    end

    ##
    # Logs a debug level message
    #
    # @param (see info)
    def debug(message)
      logger.debug(PROG_NAME) { message }
    end

    ##
    # Parses and sets proxy from a uri
    #
    # @param uri [String, #to_s] The URI to parse and extract proxy details from
    # @return [void]
    def parse_proxy(uri)
      proxy = URI.parse(uri)
      self.proxy_host = proxy.host
      self.proxy_port = proxy.port
      self.proxy_user = proxy.user
      self.proxy_password = proxy.password
    end

    ##
    # Sets the maximum allowable amount of breadcrumbs
    #
    # @param new_max_breadcrumbs [Integer] the new maximum breadcrumb limit
    # @return [void]
    def max_breadcrumbs=(new_max_breadcrumbs)
      @max_breadcrumbs = new_max_breadcrumbs
      breadcrumbs.max_items = new_max_breadcrumbs
    end

    ##
    # Returns the breadcrumb circular buffer
    #
    # @return [Bugsnag::Utility::CircularBuffer] a thread based circular buffer containing breadcrumbs
    def breadcrumbs
      request_data[:breadcrumbs] ||= Bugsnag::Utility::CircularBuffer.new(@max_breadcrumbs)
    end

    # Sets the notification endpoint
    #
    # @deprecated Use {#set_endpoints} instead
    #
    # @param new_notify_endpoint [String] The URL to deliver error notifications to
    # @return [void]
    def endpoint=(new_notify_endpoint)
      warn("The 'endpoint' configuration option is deprecated. The 'set_endpoints' method should be used instead")
      set_endpoints(new_notify_endpoint, session_endpoint) # Pass the existing session_endpoint through so it doesn't get overwritten
    end

    ##
    # Sets the sessions endpoint
    #
    # @deprecated Use {#set_endpoints} instead
    #
    # @param new_session_endpoint [String] The URL to deliver session notifications to
    # @return [void]
    def session_endpoint=(new_session_endpoint)
      warn("The 'session_endpoint' configuration option is deprecated. The 'set_endpoints' method should be used instead")
      set_endpoints(notify_endpoint, new_session_endpoint) # Pass the existing notify_endpoint through so it doesn't get overwritten
    end

    ##
    # Sets the notification and session endpoints
    #
    # @param new_notify_endpoint [String] The URL to deliver error notifications to
    # @param new_session_endpoint [String] The URL to deliver session notifications to
    # @return [void]
    def set_endpoints(new_notify_endpoint, new_session_endpoint)
      @notify_endpoint = new_notify_endpoint
      @session_endpoint = new_session_endpoint
    end

    ##
    # Disables session tracking and delivery. Cannot be undone
    #
    # @return [void]
    def disable_sessions
      self.auto_capture_sessions = false
      @enable_sessions = false
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
      middleware.use(callback)
    end

    ##
    # Remove the given callback from the list of on_error callbacks
    #
    # Note that this must be the same instance that was passed to
    # {#add_on_error}, otherwise it will not be removed
    #
    # @param callback [Proc, Method, #call]
    # @return [void]
    def remove_on_error(callback)
      middleware.remove(callback)
    end

    private

    attr_writer :scopes_to_filter

    PROG_NAME = "[Bugsnag]"

    def default_hostname
      # Send the heroku dyno name instead of hostname if available
      ENV["DYNO"] || Socket.gethostname;
    end
  end
end
