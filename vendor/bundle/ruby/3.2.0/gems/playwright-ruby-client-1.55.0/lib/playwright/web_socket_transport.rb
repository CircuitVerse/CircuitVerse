# frozen_string_literal: true

require 'json'

module Playwright
  # ref: https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_transport.py
  class WebSocketTransport
    # @param ws_endpoint [String] EndpointURL of WebSocket
    def initialize(ws_endpoint:, headers:)
      @ws_endpoint = ws_endpoint
      @headers = headers
      @debug = ENV['DEBUG'].to_s == 'true' || ENV['DEBUG'].to_s == '1'
    end

    def on_message_received(&block)
      @on_message = block
    end

    def on_driver_closed(&block)
      @on_driver_closed = block
    end

    def on_driver_crashed(&block)
      @on_driver_crashed = block
    end

    class AlreadyDisconnectedError < StandardError ; end

    # @param message [Hash]
    def send_message(message)
      debug_send_message(message) if @debug
      msg = JSON.dump(message)

      @ws.send_text(msg)
    rescue Errno::EPIPE, IOError
      raise AlreadyDisconnectedError.new('send_message failed')
    end

    # Terminate playwright-cli driver.
    def stop
      return unless @ws

      future = Concurrent::Promises.resolvable_future

      @ws.on_close do
        future.fulfill(nil)
      end

      begin
        @ws.close
      rescue EOFError => err
        # ignore EOLError. The connection is already closed.
        future.fulfill(err)
      end

      # Wait for closed actually.
      future.value!(2)
    end

    # Start `playwright-cli run-driver`
    #
    # @note This method blocks until playwright-cli exited. Consider using Thread or Future.
    def async_run
      ws = WebSocketClient.new(
        url: @ws_endpoint,
        max_payload_size: 256 * 1024 * 1024, # 256MB
        headers: @headers,
      )
      promise = Concurrent::Promises.resolvable_future
      ws.on_open do
        promise.fulfill(ws)
      end
      ws.on_error do |error_message|
        promise.reject(WebSocketClient::TransportError.new(error_message))
      end

      # Some messages can be sent just after start, before setting @ws.on_message
      # So set this handler before ws.start.
      ws.on_message do |data|
        handle_on_message(data)
      end

      ws.start
      @ws = promise.value!
      @ws.on_close do |reason, code|
        puts "[WebSocketTransport] closed with code: #{code}, reason: #{reason}"
        @on_driver_closed&.call(reason, code)
      end
      @ws.on_error do |error|
        puts "[WebSocketTransport] error: #{error}"
        @on_driver_crashed&.call
      end
    rescue Errno::ECONNREFUSED => err
      raise WebSocketClient::TransportError.new(err)
    end

    private

    def handle_on_message(data)
      obj = JSON.parse(data)

      debug_recv_message(obj) if @debug
      @on_message&.call(obj)
    end

    def debug_send_message(message)
      metadata = message.delete(:metadata)
      puts "\x1b[33mSEND>\x1b[0m#{message}"
      message[:metadata] = metadata
    end

    def debug_recv_message(message)
      puts "\x1b[33mRECV>\x1b[0m#{message}"
    end
  end
end
