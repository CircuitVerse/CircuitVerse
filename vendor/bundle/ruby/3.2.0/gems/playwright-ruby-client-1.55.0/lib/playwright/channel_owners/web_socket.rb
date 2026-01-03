require 'base64'

module Playwright
  define_channel_owner :WebSocket do
    private def after_initialize
      @closed = false

      @channel.on('frameSent', -> (params) {
        on_frame_sent(params['opcode'], params['data'])
      })
      @channel.on('frameReceived', -> (params) {
        on_frame_received(params['opcode'], params['data'])
      })
      @channel.on('socketError', -> (params) {
        emit(Events::WebSocket::Error, params['error'])
      })
      @channel.on('close', -> (_) { on_close })
    end

    def url
      @initializer['url']
    end

    class SocketClosedError < StandardError
      def initialize
        super('Socket closed')
      end
    end

    class SocketError < StandardError
      def initialize
        super('Socket error')
      end
    end

    def expect_event(event, predicate: nil, timeout: nil, &block)
      waiter = Waiter.new(self, wait_name: "WebSocket.expect_event(#{event})")
      timeout_value = timeout || @parent.send(:_timeout_settings).timeout
      waiter.reject_on_timeout(timeout_value, "Timeout #{timeout_value}ms exceeded while waiting for event \"#{event}\"")

      unless event == Events::WebSocket::Close
        waiter.reject_on_event(self, Events::WebSocket::Close, SocketClosedError.new)
      end

      unless event == Events::WebSocket::Error
        waiter.reject_on_event(self, Events::WebSocket::Error, SocketError.new)
      end

      waiter.reject_on_event(@parent, 'close', -> { @parent.send(:close_error_with_reason) })
      waiter.wait_for_event(self, event, predicate: predicate)
      block&.call

      waiter.result.value!
    end
    alias_method :wait_for_event, :expect_event

    private def on_frame_sent(opcode, data)
      if opcode == 2
        emit(Events::WebSocket::FrameSent, Base64.strict_decode64(data))
      else
        emit(Events::WebSocket::FrameSent, data)
      end
    end

    private def on_frame_received(opcode, data)
      if opcode == 2
        emit(Events::WebSocket::FrameReceived, Base64.strict_decode64(data))
      else
        emit(Events::WebSocket::FrameReceived, data)
      end
    end

    def closed?
      @closed
    end

    private def on_close
      @closed = true
      emit(Events::WebSocket::Close)
    end
  end
end
