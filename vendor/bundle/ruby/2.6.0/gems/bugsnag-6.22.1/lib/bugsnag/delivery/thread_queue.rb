require "thread"

module Bugsnag
  module Delivery
    class ThreadQueue < Synchronous
      MAX_OUTSTANDING_REQUESTS = 100
      STOP = Object.new
      MUTEX = Mutex.new

      class << self
        ##
        # Queues a given payload to be delivered asynchronously
        #
        # @param url [String]
        # @param get_payload [Proc] A Proc that will return the payload.
        # @param configuration [Bugsnag::Configuration]
        # @param options [Hash]
        # @return [void]
        def serialize_and_deliver(url, get_payload, configuration, options={})
          @configuration = configuration

          start_once!

          if @queue.length > MAX_OUTSTANDING_REQUESTS
            @configuration.warn("Dropping notification, #{@queue.length} outstanding requests")
            return
          end

          # Add delivery to the worker thread
          @queue.push(proc do
            begin
              payload = get_payload.call
            rescue StandardError => e
              configuration.warn("Notification to #{url} failed, #{e.inspect}")
              configuration.warn(e.backtrace)
            end

            Synchronous.deliver(url, payload, configuration, options) unless payload.nil?
          end)
        end

        private

        def start_once!
          MUTEX.synchronize do
            @started = nil unless defined?(@started)
            return if @started == Process.pid
            @started = Process.pid

            @queue = Queue.new

            worker_thread = Thread.new do
              while x = @queue.pop
                break if x == STOP
                x.call
              end
            end

            at_exit do
              @configuration.warn("Waiting for #{@queue.length} outstanding request(s)") unless @queue.empty?
              @queue.push STOP
              worker_thread.join
            end
          end
        end
      end
    end
  end
end

Bugsnag::Delivery.register(:thread_queue, Bugsnag::Delivery::ThreadQueue)
