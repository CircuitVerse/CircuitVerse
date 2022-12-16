require 'thread'
require 'time'
require 'securerandom'

module Bugsnag
  class SessionTracker
    THREAD_SESSION = "bugsnag_session"
    SESSION_PAYLOAD_VERSION = "1.0"
    MUTEX = Mutex.new

    attr_reader :session_counts

    ##
    # Sets the session information for this thread.
    def self.set_current_session(session)
      Thread.current[THREAD_SESSION] = session
    end

    ##
    # Returns the session information for this thread.
    def self.get_current_session
      Thread.current[THREAD_SESSION]
    end

    ##
    # Initializes the session tracker.
    def initialize
      require 'concurrent'

      @session_counts = Concurrent::Hash.new(0)
    end

    ##
    # Starts a new session, storing it on the current thread.
    #
    # This allows Bugsnag to track error rates for a release.
    #
    # @return [void]
    def start_session
      return unless Bugsnag.configuration.enable_sessions && Bugsnag.configuration.should_notify_release_stage?

      start_delivery_thread
      start_time = Time.now().utc().strftime('%Y-%m-%dT%H:%M:00')
      new_session = {
        id: SecureRandom.uuid,
        startedAt: start_time,
        paused?: false,
        events: {
          handled: 0,
          unhandled: 0
        }
      }
      SessionTracker.set_current_session(new_session)
      add_session(start_time)
    end

    alias_method :create_session, :start_session

    ##
    # Stop any events being attributed to the current session until it is
    # resumed or a new session is started
    #
    # @see resume_session
    #
    # @return [void]
    def pause_session
      current_session = SessionTracker.get_current_session

      return unless current_session

      current_session[:paused?] = true
    end

    ##
    # Resume the current session if it was previously paused. If there is no
    # current session, a new session will be started
    #
    # @see pause_session
    #
    # @return [Boolean] true if a paused session was resumed
    def resume_session
      current_session = SessionTracker.get_current_session

      if current_session
        # if the session is paused then resume it, otherwise we don't need to
        # do anything
        if current_session[:paused?]
          current_session[:paused?] = false

          return true
        end
      else
        # if there's no current session, start a new one
        start_session
      end

      false
    end

    ##
    # Delivers the current session_counts lists to the session endpoint.
    def send_sessions
      sessions = []
      counts = @session_counts
      @session_counts = Concurrent::Hash.new(0)
      counts.each do |min, count|
        sessions << {
          :startedAt => min,
          :sessionsStarted => count
        }
      end
      deliver(sessions)
    end

    private
    def start_delivery_thread
      MUTEX.synchronize do
        @started = nil unless defined?(@started)
        return if @started == Process.pid
        @started = Process.pid
        at_exit do
          if !@delivery_thread.nil?
            @delivery_thread.execute
            @delivery_thread.shutdown
          else
            if @session_counts.size > 0
              send_sessions
            end
          end
        end
        @delivery_thread = Concurrent::TimerTask.execute(execution_interval: 10) do
          if @session_counts.size > 0
            send_sessions
          end
        end
      end
    end

    def add_session(min)
      @session_counts[min] += 1
    end

    def deliver(session_payload)
      if session_payload.length == 0
        Bugsnag.configuration.debug("No sessions to deliver")
        return
      end

      if !Bugsnag.configuration.valid_api_key?
        Bugsnag.configuration.debug("Not delivering sessions due to an invalid api_key")
        return
      end

      body = {
        :notifier => {
          :name => Bugsnag::Report::NOTIFIER_NAME,
          :url => Bugsnag::Report::NOTIFIER_URL,
          :version => Bugsnag::Report::NOTIFIER_VERSION
        },
        :device => {
          :hostname => Bugsnag.configuration.hostname,
          :runtimeVersions => Bugsnag.configuration.runtime_versions
        },
        :app => {
          :version => Bugsnag.configuration.app_version,
          :releaseStage => Bugsnag.configuration.release_stage,
          :type => Bugsnag.configuration.app_type
        },
        :sessionCounts => session_payload
      }
      payload = ::JSON.dump(body)

      headers = {
        "Bugsnag-Api-Key" => Bugsnag.configuration.api_key,
        "Bugsnag-Payload-Version" => SESSION_PAYLOAD_VERSION
      }

      options = {:headers => headers}
      Bugsnag::Delivery[Bugsnag.configuration.delivery_method].deliver(Bugsnag.configuration.session_endpoint, payload, Bugsnag.configuration, options)
    end
  end
end
