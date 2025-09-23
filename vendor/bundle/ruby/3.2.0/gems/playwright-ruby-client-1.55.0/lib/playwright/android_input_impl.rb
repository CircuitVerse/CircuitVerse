module Playwright
  define_api_implementation :AndroidInputImpl do
    def initialize(channel)
      @channel = channel
    end

    def type(text)
      @channel.send_message_to_server('inputType', text: text)
    end

    def press(key)
      @channel.send_message_to_server('inputPress', key: key)
    end

    def tap_point(point)
      @channel.send_message_to_server('inputTap', point: point)
    end

    def drag(from, to, steps)
      @channel.send_message_to_server('inputDrag', from: from, to: to, steps: steps)
    end
  end
end
