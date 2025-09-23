module Playwright
  define_api_implementation :TouchscreenImpl do
    def initialize(channel)
      @channel = channel
    end

    def tap_point(x, y)
      @channel.send_message_to_server('touchscreenTap', {
        x: x,
        y: y,
      })
    end
  end
end
