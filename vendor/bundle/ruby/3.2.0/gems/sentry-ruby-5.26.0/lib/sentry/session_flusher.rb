# frozen_string_literal: true

module Sentry
  class SessionFlusher < ThreadedPeriodicWorker
    FLUSH_INTERVAL = 60

    def initialize(configuration, client)
      super(configuration.sdk_logger, FLUSH_INTERVAL)
      @client = client
      @pending_aggregates = {}
      @release = configuration.release
      @environment = configuration.environment
      @mutex = Mutex.new

      log_debug("[Sessions] Sessions won't be captured without a valid release") unless @release
    end

    def flush
      return if @pending_aggregates.empty?

      @client.capture_envelope(pending_envelope)
    end

    alias_method :run, :flush

    def add_session(session)
      return unless @release

      return unless ensure_thread

      return unless Session::AGGREGATE_STATUSES.include?(session.status)
      @pending_aggregates[session.aggregation_key] ||= init_aggregates(session.aggregation_key)
      @pending_aggregates[session.aggregation_key][session.status] += 1
    end

    private

    def init_aggregates(aggregation_key)
      aggregates = { started: aggregation_key.iso8601 }
      Session::AGGREGATE_STATUSES.each { |k| aggregates[k] = 0 }
      aggregates
    end

    def pending_envelope
      aggregates = @mutex.synchronize do
        aggregates = @pending_aggregates.values
        @pending_aggregates = {}
        aggregates
      end

      envelope = Envelope.new
      header = { type: "sessions" }
      payload = { attrs: attrs, aggregates: aggregates }
      envelope.add_item(header, payload)
      envelope
    end

    def attrs
      { release: @release, environment: @environment }
    end
  end
end
