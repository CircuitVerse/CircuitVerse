require 'openssl'
require 'socket'

begin
  require 'websocket/driver'
rescue LoadError
  raise "websocket-driver is required. Add `gem 'websocket-driver'` to your Gemfile"
end

# ref: https://github.com/rails/rails/blob/master/actioncable/lib/action_cable/connection/client_socket.rb
# ref: https://github.com/cavalle/chrome_remote/blob/master/lib/chrome_remote/web_socket_client.rb
module Playwright
  class WebSocketClient
    class SecureSocketFactory
      def initialize(host, port)
        @host = host
        @port = port || 443
      end

      def create
        tcp_socket = TCPSocket.new(@host, @port)
        OpenSSL::SSL::SSLSocket.new(tcp_socket).tap(&:connect)
      end
    end

    class DriverImpl # providing #url, #write(string)
      def initialize(url)
        @url = url

        endpoint = URI.parse(url)
        @socket =
          if endpoint.scheme == 'wss'
            SecureSocketFactory.new(endpoint.host, endpoint.port).create
          else
            TCPSocket.new(endpoint.host, endpoint.port)
          end
      end

      attr_reader :url

      def write(data)
        @socket.write(data)
      rescue Errno::EPIPE
        raise EOFError.new('already closed')
      rescue Errno::ECONNRESET
        raise EOFError.new('closed by remote')
      end

      def readpartial(maxlen = 1024)
        @socket.readpartial(maxlen)
      rescue Errno::ECONNRESET
        raise EOFError.new('closed by remote')
      end

      def disconnect
        @socket.close
      end
    end

    STATE_CONNECTING = 0
    STATE_OPENED = 1
    STATE_CLOSING = 2
    STATE_CLOSED = 3

    def initialize(url:, max_payload_size:, headers:)
      @impl = DriverImpl.new(url)
      @driver = ::WebSocket::Driver.client(@impl, max_length: max_payload_size)
      headers.each do |key, value|
        @driver.set_header(key, value)
      end

      setup
    end

    class TransportError < StandardError; end

    private def setup
      @ready_state = STATE_CONNECTING
      @driver.on(:open) do
        @ready_state = STATE_OPENED
        handle_on_open
      end
      @driver.on(:close) do |event|
        @ready_state = STATE_CLOSED
        handle_on_close(reason: event.reason, code: event.code)
      end
      @driver.on(:error) do |event|
        if !handle_on_error(error_message: event.message)
          raise TransportError.new(event.message)
        end
      end
      @driver.on(:message) do |event|
        handle_on_message(event.data)
      end
    end

    private def wait_for_data
      @driver.parse(@impl.readpartial)
    end

    def start
      @driver.start

      Thread.new do
        wait_for_data until @ready_state >= STATE_CLOSING
      rescue EOFError
        # Google Chrome was gone.
        # We have nothing todo. Just finish polling.
        if @ready_state < STATE_CLOSING
          handle_on_close(reason: 'Going Away', code: 1001)
        end
      end
    end

    # @param message [String]
    def send_text(message)
      return if @ready_state >= STATE_CLOSING
      @driver.text(message)
    end

    def close(code: 1000, reason: "")
      return if @ready_state >= STATE_CLOSING
      @ready_state = STATE_CLOSING
      @driver.close(reason, code)
    end

    def on_open(&block)
      @on_open = block
    end

    # @param block [Proc(reason: String, code: Numeric)]
    def on_close(&block)
      @on_close = block
    end

    # @param block [Proc(error_message: String)]
    def on_error(&block)
      @on_error = block
    end

    def on_message(&block)
      @on_message = block
    end

    private def handle_on_open
      @on_open&.call
    end

    private def handle_on_close(reason:, code:)
      @on_close&.call(reason, code)
      @impl.disconnect
    end

    private def handle_on_error(error_message:)
      return false if @on_error.nil?

      @on_error.call(error_message)
      true
    end

    private def handle_on_message(data)
      return if @ready_state != STATE_OPENED

      @on_message&.call(data)
    end
  end
end
