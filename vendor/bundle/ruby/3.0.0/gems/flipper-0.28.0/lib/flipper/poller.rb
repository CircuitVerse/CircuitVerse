require 'logger'
require 'concurrent/utility/monotonic_time'
require 'concurrent/map'
require 'concurrent/atomic/atomic_fixnum'

module Flipper
  class Poller
    attr_reader :adapter, :thread, :pid, :mutex, :interval, :last_synced_at

    def self.instances
      @instances ||= Concurrent::Map.new
    end
    private_class_method :instances

    def self.get(key, options = {})
      instances.compute_if_absent(key) { new(options) }
    end

    def self.reset
      instances.each {|_,poller| poller.stop }.clear
    end

    def initialize(options = {})
      @thread = nil
      @pid = Process.pid
      @mutex = Mutex.new
      @instrumenter = options.fetch(:instrumenter, Instrumenters::Noop)
      @remote_adapter = options.fetch(:remote_adapter)
      @interval = options.fetch(:interval, 10).to_f
      @last_synced_at = Concurrent::AtomicFixnum.new(0)
      @adapter = Adapters::Memory.new

      if @interval < 1
        warn "Flipper::Cloud poll interval must be greater than or equal to 1 but was #{@interval}. Setting @interval to 1."
        @interval = 1
      end

      @start_automatically = options.fetch(:start_automatically, true)

      if options.fetch(:shutdown_automatically, true)
        at_exit { stop }
      end
    end

    def start
      reset if forked?
      ensure_worker_running
    end

    def stop
      @instrumenter.instrument("poller.#{InstrumentationNamespace}", {
        operation: :stop,
      })
      @thread&.kill
    end

    def run
      loop do
        sleep jitter
        start = Concurrent.monotonic_time
        begin
          sync
        rescue => exception
          # you can instrument these using poller.flipper
        end

        sleep_interval = interval - (Concurrent.monotonic_time - start)
        sleep sleep_interval if sleep_interval.positive?
      end
    end

    def sync
      @instrumenter.instrument("poller.#{InstrumentationNamespace}", operation: :poll) do
        @adapter.import @remote_adapter
        @last_synced_at.update { |time| Concurrent.monotonic_time }
      end
    end

    private

    def jitter
      rand
    end

    def forked?
      pid != Process.pid
    end

    def ensure_worker_running
      # Return early if thread is alive and avoid the mutex lock and unlock.
      return if thread_alive?

      # If another thread is starting worker thread, then return early so this
      # thread can enqueue and move on with life.
      return unless mutex.try_lock

      begin
        return if thread_alive?
        @thread = Thread.new { run }
        @instrumenter.instrument("poller.#{InstrumentationNamespace}", {
          operation: :thread_start,
        })
      ensure
        mutex.unlock
      end
    end

    def thread_alive?
      @thread && @thread.alive?
    end

    def reset
      @pid = Process.pid
      mutex.unlock if mutex.locked?
    end
  end
end
