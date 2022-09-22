# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'socket'
require 'net/https'
require 'net/http'
require 'logger'
require 'zlib'
require 'stringio'
require 'new_relic/constants'
require 'new_relic/traced_thread'
require 'new_relic/coerce'
require 'new_relic/agent/autostart'
require 'new_relic/agent/harvester'
require 'new_relic/agent/hostname'
require 'new_relic/agent/new_relic_service'
require 'new_relic/agent/pipe_service'
require 'new_relic/agent/configuration/manager'
require 'new_relic/agent/database'
require 'new_relic/agent/instrumentation/resque/helper'
require 'new_relic/agent/commands/agent_command_router'
require 'new_relic/agent/event_listener'
require 'new_relic/agent/distributed_tracing'
require 'new_relic/agent/monitors'
require 'new_relic/agent/transaction_event_recorder'
require 'new_relic/agent/custom_event_aggregator'
require 'new_relic/agent/span_event_aggregator'
require 'new_relic/agent/log_event_aggregator'
require 'new_relic/agent/sampler_collection'
require 'new_relic/agent/javascript_instrumentor'
require 'new_relic/agent/vm/monotonic_gc_profiler'
require 'new_relic/agent/utilization_data'
require 'new_relic/environment_report'
require 'new_relic/agent/attribute_filter'
require 'new_relic/agent/adaptive_sampler'
require 'new_relic/agent/connect/request_builder'
require 'new_relic/agent/connect/response_handler'

module NewRelic
  module Agent
    # The Agent is a singleton that is instantiated when the plugin is
    # activated.  It collects performance data from ruby applications
    # in realtime as the application runs, and periodically sends that
    # data to the NewRelic server.
    class Agent
      def self.config
        ::NewRelic::Agent.config
      end

      def initialize
        @started = false
        @event_loop = nil
        @worker_thread = nil

        @service = NewRelicService.new

        @events = EventListener.new
        @stats_engine = StatsEngine.new
        @transaction_sampler = TransactionSampler.new
        @sql_sampler = SqlSampler.new
        @agent_command_router = Commands::AgentCommandRouter.new @events
        @monitors = Monitors.new @events
        @error_collector = ErrorCollector.new @events
        @transaction_rules = RulesEngine.new
        @harvest_samplers = SamplerCollection.new @events
        @monotonic_gc_profiler = VM::MonotonicGCProfiler.new
        @javascript_instrumentor = JavascriptInstrumentor.new @events
        @adaptive_sampler = AdaptiveSampler.new(Agent.config[:sampling_target],
          Agent.config[:sampling_target_period_in_seconds])

        @harvester = Harvester.new @events
        @after_fork_lock = Mutex.new

        @transaction_event_recorder = TransactionEventRecorder.new @events
        @custom_event_aggregator = CustomEventAggregator.new @events
        @span_event_aggregator = SpanEventAggregator.new @events
        @log_event_aggregator = LogEventAggregator.new @events

        @connect_state = :pending
        @connect_attempts = 0
        @waited_on_connect = nil
        @connected_pid = nil

        @wait_on_connect_mutex = Mutex.new
        @wait_on_connect_condition = ConditionVariable.new

        setup_attribute_filter
      end

      def setup_attribute_filter
        refresh_attribute_filter

        @events.subscribe(:initial_configuration_complete) do
          refresh_attribute_filter
        end
      end

      def refresh_attribute_filter
        @attribute_filter = AttributeFilter.new(Agent.config)
      end

      # contains all the class-level methods for NewRelic::Agent::Agent
      module ClassMethods
        # Should only be called by NewRelic::Control - returns a
        # memoized singleton instance of the agent, creating one if needed
        def instance
          @instance ||= self.new
        end
      end

      # Holds all the methods defined on NewRelic::Agent::Agent
      # instances
      module InstanceMethods
        # the statistics engine that holds all the timeslice data
        attr_reader :stats_engine
        # the transaction sampler that handles recording transactions
        attr_reader :transaction_sampler
        attr_reader :sql_sampler
        # manages agent commands we receive from the collector, and the handlers
        attr_reader :agent_command_router
        # error collector is a simple collection of recorded errors
        attr_reader :error_collector
        attr_reader :harvest_samplers
        # whether we should record raw, obfuscated, or no sql
        attr_reader :record_sql
        # builder for JS agent scripts to inject
        attr_reader :javascript_instrumentor
        # cross application tracing ids and encoding
        attr_reader :cross_process_id
        attr_reader :cross_app_encoding_bytes
        # service for communicating with collector
        attr_accessor :service
        # Global events dispatcher. This will provides our primary mechanism
        # for agent-wide events, such as finishing configuration, error notification
        # and request before/after from Rack.
        attr_reader :events

        # listens and responds to events that need to process headers
        # for synthetics and distributed tracing
        attr_reader :monitors
        # Transaction and metric renaming rules as provided by the
        # collector on connect.  The former are applied during txns,
        # the latter during harvest.
        attr_accessor :transaction_rules
        # Responsbile for restarting the harvest thread
        attr_reader :harvester
        # GC::Profiler.total_time is not monotonic so we wrap it.
        attr_reader :monotonic_gc_profiler
        attr_reader :custom_event_aggregator
        attr_reader :span_event_aggregator
        attr_reader :log_event_aggregator
        attr_reader :transaction_event_recorder
        attr_reader :attribute_filter
        attr_reader :adaptive_sampler
        attr_reader :environment_report

        def transaction_event_aggregator
          @transaction_event_recorder.transaction_event_aggregator
        end

        def synthetics_event_aggregator
          @transaction_event_recorder.synthetics_event_aggregator
        end

        def agent_id=(agent_id)
          @service.agent_id = agent_id
        end

        # This method should be called in a forked process after a fork.
        # It assumes the parent process initialized the agent, but does
        # not assume the agent started.
        #
        # The call is idempotent, but not re-entrant.
        #
        # * It clears any metrics carried over from the parent process
        # * Restarts the sampler thread if necessary
        # * Initiates a new agent run and worker loop unless that was done
        #   in the parent process and +:force_reconnect+ is not true
        #
        # Options:
        # * <tt>:force_reconnect => true</tt> to force the spawned process to
        #   establish a new connection, such as when forking a long running process.
        #   The default is false--it will only connect to the server if the parent
        #   had not connected.
        # * <tt>:keep_retrying => false</tt> if we try to initiate a new
        #   connection, this tells me to only try it once so this method returns
        #   quickly if there is some kind of latency with the server.
        def after_fork(options = {})
          needs_restart = false
          @after_fork_lock.synchronize do
            needs_restart = @harvester.needs_restart?
            @harvester.mark_started
          end

          return if !needs_restart ||
            !Agent.config[:agent_enabled] ||
            !Agent.config[:monitor_mode] ||
            disconnected? ||
            !control.security_settings_valid?

          ::NewRelic::Agent.logger.debug "Starting the worker thread in #{Process.pid} (parent #{Process.ppid}) after forking."

          channel_id = options[:report_to_channel]
          install_pipe_service(channel_id) if channel_id

          # Clear out locks and stats left over from parent process
          reset_objects_with_locks
          drop_buffered_data

          setup_and_start_agent(options)
        end

        def install_pipe_service(channel_id)
          @service = PipeService.new(channel_id)
          if connected?
            @connected_pid = Process.pid
          else
            ::NewRelic::Agent.logger.debug("Child process #{Process.pid} not reporting to non-connected parent (process #{Process.ppid}).")
            @service.shutdown
            disconnect
          end
        end

        # True if we have initialized and completed 'start'
        def started?
          @started
        end

        # Attempt a graceful shutdown of the agent, flushing any remaining
        # data.
        def shutdown
          return unless started?
          ::NewRelic::Agent.logger.info "Starting Agent shutdown"

          stop_event_loop
          trap_signals_for_litespeed
          untraced_graceful_disconnect
          revert_to_default_configuration

          @started = nil
          Control.reset
        end

        def revert_to_default_configuration
          Agent.config.remove_config_type(:manual)
          Agent.config.remove_config_type(:server)
        end

        # If the @worker_thread encounters an error during the attempt to connect to the collector
        # then the connect attempts enter an exponential backoff retry loop.  To avoid potential
        # race conditions with shutting down while also attempting to reconnect, we join the
        # @worker_thread with a timeout threshold.  This allows potentially connecting and flushing
        # pending data to the server, but without waiting indefinitely for a reconnect to succeed.
        # The use-case where this typically arises is in cronjob scheduled rake tasks where there's
        # also some network stability/latency issues happening.
        def stop_event_loop
          @event_loop.stop if @event_loop
          # Wait the end of the event loop thread.
          if @worker_thread
            unless @worker_thread.join(3)
              ::NewRelic::Agent.logger.debug "Event loop thread did not stop within 3 seconds"
            end
          end
        end

        def trap_signals_for_litespeed
          # if litespeed, then ignore all future SIGUSR1 - it's
          # litespeed trying to shut us down
          if Agent.config[:dispatcher] == :litespeed
            Signal.trap("SIGUSR1", "IGNORE")
            Signal.trap("SIGTERM", "IGNORE")
          end
        end

        def untraced_graceful_disconnect
          begin
            NewRelic::Agent.disable_all_tracing do
              graceful_disconnect
            end
          rescue => e
            ::NewRelic::Agent.logger.error e
          end
        end

        # Sets a thread local variable as to whether we should or
        # should not record sql in the current thread. Returns the
        # previous value, if there is one
        def set_record_sql(should_record) # THREAD_LOCAL_ACCESS
          state = Tracer.state
          prev = state.record_sql
          state.record_sql = should_record
          prev.nil? || prev
        end

        # Push flag indicating whether we should be tracing in this
        # thread. This uses a stack which allows us to disable tracing
        # children of a transaction without affecting the tracing of
        # the whole transaction
        def push_trace_execution_flag(should_trace = false) # THREAD_LOCAL_ACCESS
          Tracer.state.push_traced(should_trace)
        end

        # Pop the current trace execution status.  Restore trace execution status
        # to what it was before we pushed the current flag.
        def pop_trace_execution_flag # THREAD_LOCAL_ACCESS
          Tracer.state.pop_traced
        end

        # Herein lies the corpse of the former 'start' method. May
        # its unmatched flog score rest in pieces.
        module Start
          # Check whether we have already started, which is an error condition
          def already_started?
            if started?
              ::NewRelic::Agent.logger.error("Agent Started Already!")
              true
            end
          end

          # The agent is disabled when it is not force enabled by the
          # 'agent_enabled' option (e.g. in a manual start), or
          # enabled normally through the configuration file
          def disabled?
            !Agent.config[:agent_enabled]
          end

          # Log startup information that we almost always want to know
          def log_startup
            log_environment
            log_dispatcher
            log_app_name
          end

          # Log the environment the app thinks it's running in.
          # Useful in debugging, as this is the key for config YAML lookups.
          def log_environment
            ::NewRelic::Agent.logger.info "Environment: #{NewRelic::Control.instance.env}"
          end

          # Logs the dispatcher to the log file to assist with
          # debugging. When no debugger is present, logs this fact to
          # assist with proper dispatcher detection
          def log_dispatcher
            dispatcher_name = Agent.config[:dispatcher].to_s

            if dispatcher_name.empty?
              ::NewRelic::Agent.logger.info 'No known dispatcher detected.'
            else
              ::NewRelic::Agent.logger.info "Dispatcher: #{dispatcher_name}"
            end
          end

          def log_app_name
            ::NewRelic::Agent.logger.info "Application: #{Agent.config[:app_name].join(", ")}"
          end

          def log_ignore_url_regexes
            regexes = NewRelic::Agent.config[:'rules.ignore_url_regexes']

            unless regexes.empty?
              ::NewRelic::Agent.logger.info "Ignoring URLs that match the following regexes: #{regexes.map(&:inspect).join(", ")}."
            end
          end

          # Logs the configured application names
          def app_name_configured?
            names = Agent.config[:app_name]
            return names.respond_to?(:any?) && names.any?
          end

          # Connecting in the foreground blocks further startup of the
          # agent until we have a connection - useful in cases where
          # you're trying to log a very-short-running process and want
          # to get statistics from before a server connection
          # (typically 20 seconds) exists
          def connect_in_foreground
            NewRelic::Agent.disable_all_tracing { connect(:keep_retrying => false) }
          end

          # This matters when the following three criteria are met:
          #
          # 1. A Sinatra 'classic' application is being run
          # 2. The app is being run by executing the main file directly, rather
          #    than via a config.ru file.
          # 3. newrelic_rpm is required *after* sinatra
          #
          # In this case, the entire application runs from an at_exit handler in
          # Sinatra, and if we were to install ours, it would be executed before
          # the one in Sinatra, meaning that we'd shutdown the agent too early
          # and never collect any data.
          def sinatra_classic_app?
            (
              defined?(Sinatra::Application) &&
              Sinatra::Application.respond_to?(:run) &&
              Sinatra::Application.run?
            )
          end

          def should_install_exit_handler?
            return false unless Agent.config[:send_data_on_exit]
            !sinatra_classic_app? || Agent.config[:force_install_exit_handler]
          end

          def install_exit_handler
            return unless should_install_exit_handler?
            NewRelic::Agent.logger.debug("Installing at_exit handler")
            at_exit { shutdown }
          end

          # Classy logging of the agent version and the current pid,
          # so we can disambiguate processes in the log file and make
          # sure they're running a reasonable version
          def log_version_and_pid
            ::NewRelic::Agent.logger.debug "New Relic Ruby Agent #{NewRelic::VERSION::STRING} Initialized: pid = #{$$}"
          end

          # Warn the user if they have configured their agent not to
          # send data, that way we can see this clearly in the log file
          def monitoring?
            if Agent.config[:monitor_mode]
              true
            else
              ::NewRelic::Agent.logger.warn('Agent configured not to send data in this environment.')
              false
            end
          end

          # Tell the user when the license key is missing so they can
          # fix it by adding it to the file
          def has_license_key?
            if Agent.config[:license_key] && Agent.config[:license_key].length > 0
              true
            else
              ::NewRelic::Agent.logger.warn("No license key found. " +
                "This often means your newrelic.yml file was not found, or it lacks a section for the running environment, '#{NewRelic::Control.instance.env}'. You may also want to try linting your newrelic.yml to ensure it is valid YML.")
              false
            end
          end

          # A correct license key exists and is of the proper length
          def has_correct_license_key?
            has_license_key? && correct_license_length
          end

          # A license key is an arbitrary 40 character string,
          # usually looks something like a SHA1 hash
          def correct_license_length
            key = Agent.config[:license_key]

            if key.length == 40
              true
            else
              ::NewRelic::Agent.logger.error("Invalid license key: #{key}")
              false
            end
          end

          # If we're using a dispatcher that forks before serving
          # requests, we need to wait until the children are forked
          # before connecting, otherwise the parent process sends useless data
          def using_forking_dispatcher?
            # TODO: MAJOR VERSION - remove :rainbows
            if [:puma, :passenger, :rainbows, :unicorn].include? Agent.config[:dispatcher]
              ::NewRelic::Agent.logger.info "Deferring startup of agent reporting thread because #{Agent.config[:dispatcher]} may fork."
              true
            else
              false
            end
          end

          # Return true if we're using resque and it hasn't had a chance to (potentially)
          # daemonize itself. This avoids hanging when there's a Thread started
          # before Resque calls Process.daemon (Jira RUBY-857)
          def defer_for_resque?
            NewRelic::Agent.config[:dispatcher] == :resque &&
              NewRelic::Agent::Instrumentation::Resque::Helper.resque_fork_per_job? &&
              !PipeChannelManager.listener.started?
          end

          def in_resque_child_process?
            defined?(@service) && @service.is_a?(PipeService)
          end

          # Sanity-check the agent configuration and start the agent,
          # setting up the worker thread and the exit handler to shut
          # down the agent
          def check_config_and_start_agent
            return unless monitoring? && has_correct_license_key?
            return if using_forking_dispatcher?
            setup_and_start_agent
          end

          # This is the shared method between the main agent startup and the
          # after_fork call restarting the thread in deferred dispatchers.
          #
          # Treatment of @started and env report is important to get right.
          def setup_and_start_agent(options = {})
            @started = true
            @harvester.mark_started

            unless in_resque_child_process?
              install_exit_handler
              environment_for_connect
              @harvest_samplers.load_samplers unless Agent.config[:disable_samplers]
            end

            connect_in_foreground if Agent.config[:sync_startup]
            start_worker_thread(options)
          end
        end

        include Start

        def defer_for_delayed_job?
          NewRelic::Agent.config[:dispatcher] == :delayed_job &&
            !NewRelic::DelayedJobInjection.worker_name
        end

        # Check to see if the agent should start, returning +true+ if it should.
        def agent_should_start?
          return false if already_started? || disabled?

          if defer_for_delayed_job?
            ::NewRelic::Agent.logger.debug "Deferring startup for DelayedJob"
            return false
          end

          if defer_for_resque?
            ::NewRelic::Agent.logger.debug "Deferring startup for Resque in case it daemonizes"
            return false
          end

          unless app_name_configured?
            NewRelic::Agent.logger.error "No application name configured.",
              "The Agent cannot start without at least one. Please check your ",
              "newrelic.yml and ensure that it is valid and has at least one ",
              "value set for app_name in the #{NewRelic::Control.instance.env} ",
              "environment."
            return false
          end

          return true
        end

        # Logs a bunch of data and starts the agent, if needed
        def start
          return unless agent_should_start?

          log_startup
          check_config_and_start_agent
          log_version_and_pid

          events.subscribe(:initial_configuration_complete) do
            log_ignore_url_regexes
          end
        end

        # Clear out the metric data, errors, and transaction traces, etc.
        def drop_buffered_data
          @stats_engine.reset!
          @error_collector.drop_buffered_data
          @transaction_sampler.reset!
          @transaction_event_recorder.drop_buffered_data
          @custom_event_aggregator.reset!
          @span_event_aggregator.reset!
          @log_event_aggregator.reset!
          @sql_sampler.reset!

          if Agent.config[:clear_transaction_state_after_fork]
            Tracer.clear_state
          end
        end

        # Clear out state for any objects that we know lock from our parents
        # This is necessary for cases where we're in a forked child and Ruby
        # might be holding locks for background thread that aren't there anymore.
        def reset_objects_with_locks
          @stats_engine = StatsEngine.new
        end

        def flush_pipe_data
          if connected? && @service.is_a?(PipeService)
            transmit_data
            transmit_analytic_event_data
            transmit_custom_event_data
            transmit_error_event_data
            transmit_span_event_data
            transmit_log_event_data
          end
        end

        private

        # All of this module used to be contained in the
        # start_worker_thread method - this is an artifact of
        # refactoring and can be moved, renamed, etc at will
        module StartWorkerThread
          def create_event_loop
            EventLoop.new
          end

          LOG_ONCE_KEYS_RESET_PERIOD = 60.0

          # Certain event types may sometimes need to be on the same interval as metrics,
          # so we will check config assigned in EventHarvestConfig to determine the interval
          # on which to report them
          def interval_for event_type
            interval = Agent.config[:"event_report_period.#{event_type}"]
            :"#{interval}_second_harvest"
          end

          TRANSACTION_EVENT_DATA = "transaction_event_data".freeze
          CUSTOM_EVENT_DATA = "custom_event_data".freeze
          ERROR_EVENT_DATA = "error_event_data".freeze
          SPAN_EVENT_DATA = "span_event_data".freeze
          LOG_EVENT_DATA = "log_event_data".freeze

          def create_and_run_event_loop
            data_harvest = :"#{Agent.config[:data_report_period]}_second_harvest"
            event_harvest = :"#{Agent.config[:event_report_period]}_second_harvest"

            @event_loop = create_event_loop
            @event_loop.on(data_harvest) do
              transmit_data
            end

            @event_loop.on(interval_for TRANSACTION_EVENT_DATA) do
              transmit_analytic_event_data
            end
            @event_loop.on(interval_for CUSTOM_EVENT_DATA) do
              transmit_custom_event_data
            end
            @event_loop.on(interval_for ERROR_EVENT_DATA) do
              transmit_error_event_data
            end
            @event_loop.on(interval_for SPAN_EVENT_DATA) do
              transmit_span_event_data
            end
            @event_loop.on(interval_for LOG_EVENT_DATA) do
              transmit_log_event_data
            end

            @event_loop.on(:reset_log_once_keys) do
              ::NewRelic::Agent.logger.clear_already_logged
            end
            @event_loop.fire_every(Agent.config[:data_report_period], data_harvest)
            @event_loop.fire_every(Agent.config[:event_report_period], event_harvest)
            @event_loop.fire_every(LOG_ONCE_KEYS_RESET_PERIOD, :reset_log_once_keys)

            @event_loop.run
          end

          # Handles the case where the server tells us to restart -
          # this clears the data, clears connection attempts, and
          # waits a while to reconnect.
          def handle_force_restart(error)
            ::NewRelic::Agent.logger.debug error.message
            drop_buffered_data
            @service.force_restart if @service
            @connect_state = :pending
            sleep 30
          end

          # when a disconnect is requested, stop the current thread, which
          # is the worker thread that gathers data and talks to the
          # server.
          def handle_force_disconnect(error)
            ::NewRelic::Agent.logger.warn "Agent received a ForceDisconnectException from the server, disconnecting. (#{error.message})"
            disconnect
          end

          # Handles an unknown error in the worker thread by logging
          # it and disconnecting the agent, since we are now in an
          # unknown state.
          def handle_other_error(error)
            ::NewRelic::Agent.logger.error "Unhandled error in worker thread, disconnecting."
            # These errors are fatal (that is, they will prevent the agent from
            # reporting entirely), so we really want backtraces when they happen
            ::NewRelic::Agent.logger.log_exception(:error, error)
            disconnect
          end

          # a wrapper method to handle all the errors that can happen
          # in the connection and worker thread system. This
          # guarantees a no-throw from the background thread.
          def catch_errors
            yield
          rescue NewRelic::Agent::ForceRestartException => e
            handle_force_restart(e)
            retry
          rescue NewRelic::Agent::ForceDisconnectException => e
            handle_force_disconnect(e)
          rescue => e
            handle_other_error(e)
          end

          # This is the method that is run in a new thread in order to
          # background the harvesting and sending of data during the
          # normal operation of the agent.
          #
          # Takes connection options that determine how we should
          # connect to the server, and loops endlessly - typically we
          # never return from this method unless we're shutting down
          # the agent
          def deferred_work!(connection_options)
            catch_errors do
              NewRelic::Agent.disable_all_tracing do
                connect(connection_options)
                if connected?
                  create_and_run_event_loop
                  # never reaches here unless there is a problem or
                  # the agent is exiting
                else
                  ::NewRelic::Agent.logger.debug "No connection.  Worker thread ending."
                end
              end
            end
          end
        end
        include StartWorkerThread

        # Try to launch the worker thread and connect to the server.
        #
        # See #connect for a description of connection_options.
        def start_worker_thread(connection_options = {})
          if disable = NewRelic::Agent.config[:disable_harvest_thread]
            NewRelic::Agent.logger.info "Not starting Ruby Agent worker thread because :disable_harvest_thread is #{disable}"
            return
          end

          ::NewRelic::Agent.logger.debug "Creating Ruby Agent worker thread."
          @worker_thread = Threading::AgentThread.create('Worker Loop') do
            deferred_work!(connection_options)
          end
        end

        # A shorthand for NewRelic::Control.instance
        def control
          NewRelic::Control.instance
        end

        # This module is an artifact of a refactoring of the connect
        # method - all of its methods are used in that context, so it
        # can be refactored at will. It should be fully tested
        module Connect
          # number of attempts we've made to contact the server
          attr_accessor :connect_attempts

          # Disconnect just sets the connect state to disconnected, preventing
          # further retries.
          def disconnect
            @connect_state = :disconnected
            true
          end

          def connected?
            @connect_state == :connected
          end

          def disconnected?
            @connect_state == :disconnected
          end

          # Don't connect if we're already connected, or if we tried to connect
          # and were rejected with prejudice because of a license issue, unless
          # we're forced to by force_reconnect.
          def should_connect?(force = false)
            force || (!connected? && !disconnected?)
          end

          # Per the spec at
          # /agents/agent-specs/Collector-Response-Handling.md, retry
          # connections after a specific backoff sequence to prevent
          # hammering the server.
          def connect_retry_period
            NewRelic::CONNECT_RETRY_PERIODS[connect_attempts] || NewRelic::MAX_RETRY_PERIOD
          end

          def note_connect_failure
            self.connect_attempts += 1
          end

          # When we have a problem connecting to the server, we need
          # to tell the user what happened, since this is not an error
          # we can handle gracefully.
          def log_error(error)
            ::NewRelic::Agent.logger.error "Error establishing connection with New Relic Service at #{control.server}:", error
          end

          # When the server sends us an error with the license key, we
          # want to tell the user that something went wrong, and let
          # them know where to go to get a valid license key
          #
          # After this runs, it disconnects the agent so that it will
          # no longer try to connect to the server, saving the
          # application and the server load
          def handle_license_error(error)
            ::NewRelic::Agent.logger.error( \
              error.message, \
              "Visit NewRelic.com to obtain a valid license key, or to upgrade your account."
            )
            disconnect
          end

          def handle_unrecoverable_agent_error(error)
            ::NewRelic::Agent.logger.error(error.message)
            disconnect
            shutdown
          end

          # Checks whether we should send environment info, and if so,
          # returns the snapshot from the local environment.
          # Generating the EnvironmentReport has the potential to trigger
          # require calls in Rails environments, so this method should only
          # be called synchronously from on the main thread.
          def environment_for_connect
            @environment_report ||= Agent.config[:send_environment_info] ? Array(EnvironmentReport.new) : []
          end

          # Constructs and memoizes an event_harvest_config hash to be used in
          # the payload sent during connect (and reconnect)
          def event_harvest_config
            @event_harvest_config ||= Configuration::EventHarvestConfig.from_config(Agent.config)
          end

          # Builds the payload to send to the connect service,
          # connects, then configures the agent using the response from
          # the connect service
          def connect_to_server
            request_builder = ::NewRelic::Agent::Connect::RequestBuilder.new \
              @service,
              Agent.config,
              event_harvest_config,
              environment_for_connect
            connect_response = @service.connect request_builder.connect_payload

            response_handler = ::NewRelic::Agent::Connect::ResponseHandler.new(self, Agent.config)
            response_handler.configure_agent(connect_response)

            log_connection connect_response if connect_response
            connect_response
          end

          # Logs when we connect to the server, for debugging purposes
          # - makes sure we know if an agent has not connected
          def log_connection(config_data)
            ::NewRelic::Agent.logger.debug "Connected to NewRelic Service at #{@service.collector.name}"
            ::NewRelic::Agent.logger.debug "Agent Run       = #{@service.agent_id}."
            ::NewRelic::Agent.logger.debug "Connection data = #{config_data.inspect}"
            if config_data['messages'] && config_data['messages'].any?
              log_collector_messages(config_data['messages'])
            end
          end

          def log_collector_messages(messages)
            messages.each do |message|
              ::NewRelic::Agent.logger.send(message['level'].downcase, message['message'])
            end
          end

          # apdex_f is always 4 times the apdex_t
          def apdex_f
            (4 * Agent.config[:apdex_t]).to_f
          end

          class WaitOnConnectTimeout < StandardError
          end

          # Used for testing to let us know we've actually started to wait
          def waited_on_connect?
            @waited_on_connect
          end

          def signal_connected
            @wait_on_connect_mutex.synchronize do
              @wait_on_connect_condition.signal
            end
          end

          def wait_on_connect(timeout)
            return if connected?

            @waited_on_connect = true
            NewRelic::Agent.logger.debug("Waiting on connect to complete.")

            @wait_on_connect_mutex.synchronize do
              @wait_on_connect_condition.wait(@wait_on_connect_mutex, timeout)
            end

            unless connected?
              raise WaitOnConnectTimeout, "Agent was unable to connect in #{timeout} seconds."
            end
          end
        end
        include Connect

        def container_for_endpoint(endpoint)
          case endpoint
          when :metric_data then @stats_engine
          when :transaction_sample_data then @transaction_sampler
          when :error_data then @error_collector.error_trace_aggregator
          when :error_event_data then @error_collector.error_event_aggregator
          when :analytic_event_data then transaction_event_aggregator
          when :custom_event_data then @custom_event_aggregator
          when :span_event_data then span_event_aggregator
          when :sql_trace_data then @sql_sampler
          when :log_event_data then @log_event_aggregator
          end
        end

        def merge_data_for_endpoint(endpoint, data)
          if data && !data.empty?
            container = container_for_endpoint endpoint
            if container.respond_to?(:has_metadata?) && container.has_metadata?
              container_for_endpoint(endpoint).merge!(data, false)
            else
              container_for_endpoint(endpoint).merge!(data)
            end
          end
        rescue => e
          NewRelic::Agent.logger.error("Error while merging #{endpoint} data from child: ", e)
        end

        public :merge_data_for_endpoint

        # Establish a connection to New Relic servers.
        #
        # By default, if a connection has already been established, this method
        # will be a no-op.
        #
        # @param [Hash] options
        # @option options [Boolean] :keep_retrying (true)
        #   If true, this method will block until a connection is successfully
        #   established, continuing to retry upon failure. If false, this method
        #   will return after either successfully connecting, or after failing
        #   once.
        #
        # @option options [Boolean] :force_reconnect (false)
        #   If true, this method will force establishment of a new connection
        #   with New Relic, even if there is already an existing connection.
        #   This is useful primarily when re-establishing a new connection after
        #   forking off from a parent process.
        #
        def connect(options = {})
          defaults = {
            :keep_retrying => Agent.config[:keep_retrying],
            :force_reconnect => Agent.config[:force_reconnect]
          }
          opts = defaults.merge(options)

          return unless should_connect?(opts[:force_reconnect])

          ::NewRelic::Agent.logger.debug "Connecting Process to New Relic: #$0"
          connect_to_server
          @connected_pid = $$
          @connect_state = :connected
          signal_connected
        rescue NewRelic::Agent::ForceDisconnectException => e
          handle_force_disconnect(e)
        rescue NewRelic::Agent::LicenseException => e
          handle_license_error(e)
        rescue NewRelic::Agent::UnrecoverableAgentException => e
          handle_unrecoverable_agent_error(e)
        rescue StandardError, Timeout::Error, NewRelic::Agent::ServerConnectionException => e
          # Allow a killed (aborting) thread to continue exiting during shutdown.
          # See: https://github.com/newrelic/newrelic-ruby-agent/issues/340
          raise if Thread.current.status == 'aborting'

          log_error(e)
          if opts[:keep_retrying]
            note_connect_failure
            ::NewRelic::Agent.logger.info "Will re-attempt in #{connect_retry_period} seconds"
            sleep connect_retry_period
            retry
          end
        rescue Exception => e
          ::NewRelic::Agent.logger.error "Exception of unexpected type during Agent#connect():", e

          raise
        end

        # Delegates to the control class to determine the root
        # directory of this project
        def determine_home_directory
          control.root
        end

        # Harvests data from the given container, sends it to the named endpoint
        # on the service, and automatically merges back in upon a recoverable
        # failure.
        #
        # The given container should respond to:
        #
        #  #harvest!
        #    returns a payload that contains enumerable collection of data items and
        #    optional metadata to be sent to the collector.
        #
        #  #reset!
        #    drop any stored data and reset to a clean state.
        #
        #  #merge!(payload)
        #    merge the given payload back into the internal buffer of the
        #    container, so that it may be harvested again later.
        #
        def harvest_and_send_from_container(container, endpoint)
          payload = harvest_from_container(container, endpoint)
          sample_count = harvest_size container, payload
          if sample_count > 0
            NewRelic::Agent.logger.debug("Sending #{sample_count} items to #{endpoint}")
            send_data_to_endpoint(endpoint, payload, container)
          end
        end

        def harvest_size container, items
          if container.respond_to?(:has_metadata?) && container.has_metadata? && !items.empty?
            items.last.size
          else
            items.size
          end
        end

        def harvest_from_container(container, endpoint)
          items = []
          begin
            items = container.harvest!
          rescue => e
            NewRelic::Agent.logger.error("Failed to harvest #{endpoint} data, resetting. Error: ", e)
            container.reset!
          end
          items
        end

        def send_data_to_endpoint(endpoint, payload, container)
          begin
            @service.send(endpoint, payload)
          rescue ForceRestartException, ForceDisconnectException
            raise
          rescue SerializationError => e
            NewRelic::Agent.logger.warn("Failed to serialize data for #{endpoint}, discarding. Error: ", e)
          rescue UnrecoverableServerException => e
            NewRelic::Agent.logger.warn("#{endpoint} data was rejected by remote service, discarding. Error: ", e)
          rescue ServerConnectionException => e
            log_remote_unavailable(endpoint, e)
            container.merge!(payload)
          rescue => e
            NewRelic::Agent.logger.info("Unable to send #{endpoint} data, will try again later. Error: ", e)
            container.merge!(payload)
          end
        end

        def harvest_and_send_timeslice_data
          TransactionTimeAggregator.harvest!
          harvest_and_send_from_container(@stats_engine, :metric_data)
        end

        def harvest_and_send_slowest_sql
          harvest_and_send_from_container(@sql_sampler, :sql_trace_data)
        end

        # This handles getting the transaction traces and then sending
        # them across the wire.  This includes gathering SQL
        # explanations, stripping out stack traces, and normalizing
        # SQL.  note that we explain only the sql statements whose
        # nodes' execution times exceed our threshold (to avoid
        # unnecessary overhead of running explains on fast queries.)
        def harvest_and_send_transaction_traces
          harvest_and_send_from_container(@transaction_sampler, :transaction_sample_data)
        end

        def harvest_and_send_for_agent_commands
          harvest_and_send_from_container(@agent_command_router, :profile_data)
        end

        def harvest_and_send_errors
          harvest_and_send_from_container(@error_collector.error_trace_aggregator, :error_data)
        end

        def harvest_and_send_analytic_event_data
          harvest_and_send_from_container(transaction_event_aggregator, :analytic_event_data)
          harvest_and_send_from_container(synthetics_event_aggregator, :analytic_event_data)
        end

        def harvest_and_send_custom_event_data
          harvest_and_send_from_container(@custom_event_aggregator, :custom_event_data)
        end

        def harvest_and_send_error_event_data
          harvest_and_send_from_container @error_collector.error_event_aggregator, :error_event_data
        end

        def harvest_and_send_span_event_data
          harvest_and_send_from_container(span_event_aggregator, :span_event_data)
        end

        def harvest_and_send_log_event_data
          harvest_and_send_from_container(@log_event_aggregator, :log_event_data)
        end

        def check_for_and_handle_agent_commands
          begin
            @agent_command_router.check_for_and_handle_agent_commands
          rescue ForceRestartException, ForceDisconnectException
            raise
          rescue UnrecoverableServerException => e
            NewRelic::Agent.logger.warn("get_agent_commands message was rejected by remote service, discarding. Error: ", e)
          rescue ServerConnectionException => e
            log_remote_unavailable(:get_agent_commands, e)
          rescue => e
            NewRelic::Agent.logger.info("Error during check_for_and_handle_agent_commands, will retry later: ", e)
          end
        end

        def log_remote_unavailable(endpoint, e)
          NewRelic::Agent.logger.debug("Unable to send #{endpoint} data, will try again later. Error: ", e)
          NewRelic::Agent.record_metric("Supportability/remote_unavailable", 0.0)
          NewRelic::Agent.record_metric("Supportability/remote_unavailable/#{endpoint.to_s}", 0.0)
        end

        TRANSACTION_EVENT = "TransactionEvent".freeze
        def transmit_analytic_event_data
          transmit_single_data_type(:harvest_and_send_analytic_event_data, TRANSACTION_EVENT)
        end

        CUSTOM_EVENT = "CustomEvent".freeze
        def transmit_custom_event_data
          transmit_single_data_type(:harvest_and_send_custom_event_data, CUSTOM_EVENT)
        end

        ERROR_EVENT = "ErrorEvent".freeze
        def transmit_error_event_data
          transmit_single_data_type(:harvest_and_send_error_event_data, ERROR_EVENT)
        end

        SPAN_EVENT = "SpanEvent".freeze
        def transmit_span_event_data
          transmit_single_data_type(:harvest_and_send_span_event_data, SPAN_EVENT)
        end

        LOG_EVENT = "LogEvent".freeze
        def transmit_log_event_data
          transmit_single_data_type(:harvest_and_send_log_event_data, LOG_EVENT)
        end

        def transmit_single_data_type(harvest_method, supportability_name)
          now = Process.clock_gettime(Process::CLOCK_MONOTONIC)

          msg = "Sending #{supportability_name} data to New Relic Service"
          ::NewRelic::Agent.logger.debug msg

          @service.session do # use http keep-alive
            self.send(harvest_method)
          end
        ensure
          duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - now
          NewRelic::Agent.record_metric("Supportability/#{supportability_name}Harvest", duration)
        end

        def transmit_data
          now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          ::NewRelic::Agent.logger.debug "Sending data to New Relic Service"

          @events.notify(:before_harvest)
          @service.session do # use http keep-alive
            harvest_and_send_errors
            harvest_and_send_error_event_data
            harvest_and_send_transaction_traces
            harvest_and_send_slowest_sql
            harvest_and_send_timeslice_data
            harvest_and_send_span_event_data
            harvest_and_send_log_event_data

            check_for_and_handle_agent_commands
            harvest_and_send_for_agent_commands
          end
        ensure
          NewRelic::Agent::Database.close_connections
          duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - now
          NewRelic::Agent.record_metric('Supportability/Harvest', duration)
        end

        # This method contacts the server to send remaining data and
        # let the server know that the agent is shutting down - this
        # allows us to do things like accurately set the end of the
        # lifetime of the process
        #
        # If this process comes from a parent process, it will not
        # disconnect, so that the parent process can continue to send data
        def graceful_disconnect
          if connected?
            begin
              @service.request_timeout = 10

              @events.notify(:before_shutdown)
              transmit_data
              transmit_analytic_event_data
              transmit_custom_event_data
              transmit_error_event_data
              transmit_span_event_data
              transmit_log_event_data

              if @connected_pid == $$ && !@service.kind_of?(NewRelic::Agent::NewRelicService)
                ::NewRelic::Agent.logger.debug "Sending New Relic service agent run shutdown message"
                @service.shutdown
              else
                ::NewRelic::Agent.logger.debug "This agent connected from parent process #{@connected_pid}--not sending shutdown"
              end
              ::NewRelic::Agent.logger.debug "Graceful disconnect complete"
            rescue Timeout::Error, StandardError => e
              ::NewRelic::Agent.logger.debug "Error when disconnecting #{e.class.name}: #{e.message}"
            end
          else
            ::NewRelic::Agent.logger.debug "Bypassing graceful disconnect - agent not connected"
          end
        end
      end

      extend ClassMethods
      include InstanceMethods
    end
  end
end
