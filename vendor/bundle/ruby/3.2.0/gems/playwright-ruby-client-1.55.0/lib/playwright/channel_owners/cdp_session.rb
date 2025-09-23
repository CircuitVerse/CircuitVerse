module Playwright
  define_channel_owner :CDPSession do
    private def after_initialize
      @channel.on('event', method(:on_event))
    end

    private def on_event(params)
      emit(params['method'], params['params'])
    end

    def send_message(method, params: {})
      @channel.send_message_to_server('send', method: method, params: params)
    end

    def detach
      @channel.send_message_to_server('detach')
    end
  end
end
