# frozen_string_literal: true

require "sentry/threaded_periodic_worker"

module Sentry
  # LogEventBuffer buffers log events and sends them to Sentry in a single envelope.
  #
  # This is used internally by the `Sentry::Client`.
  #
  # @!visibility private
  class LogEventBuffer < ThreadedPeriodicWorker
    FLUSH_INTERVAL = 5 # seconds
    DEFAULT_MAX_EVENTS = 100

    # @!visibility private
    attr_reader :pending_events

    def initialize(configuration, client)
      super(configuration.sdk_logger, FLUSH_INTERVAL)

      @client = client
      @pending_events = []
      @max_events = configuration.max_log_events || DEFAULT_MAX_EVENTS
      @mutex = Mutex.new

      log_debug("[Logging] Initialized buffer with max_events=#{@max_events}, flush_interval=#{FLUSH_INTERVAL}s")
    end

    def start
      ensure_thread
      self
    end

    def flush
      @mutex.synchronize do
        return if empty?

        log_debug("[LogEventBuffer] flushing #{size} log events")

        send_events
      end

      log_debug("[LogEventBuffer] flushed #{size} log events")

      self
    end
    alias_method :run, :flush

    def add_event(event)
      raise ArgumentError, "expected a LogEvent, got #{event.class}" unless event.is_a?(LogEvent)

      @mutex.synchronize do
        @pending_events << event
        send_events if size >= @max_events
      end

      self
    end

    def empty?
      @pending_events.empty?
    end

    def size
      @pending_events.size
    end

    private

    def send_events
      @client.send_logs(@pending_events)
      @pending_events.clear
    end
  end
end
