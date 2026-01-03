module Playwright
  define_api_implementation :MouseImpl do
    def initialize(channel)
      @channel = channel
    end

    def move(x, y, steps: nil)
      params = { x: x, y: y, steps: steps }.compact
      @channel.send_message_to_server('mouseMove', params)
      nil
    end

    def down(button: nil, clickCount: nil)
      params = { button: button, clickCount: clickCount }.compact
      @channel.send_message_to_server('mouseDown', params)
      nil
    end

    def up(button: nil, clickCount: nil)
      params = { button: button, clickCount: clickCount }.compact
      @channel.send_message_to_server('mouseUp', params)
      nil
    end

    def click(
      x,
      y,
      button: nil,
      clickCount: nil,
      delay: nil)

      params = {
        x: x,
        y: y,
        button: button,
        clickCount: clickCount,
        delay: delay,
      }.compact
      @channel.send_message_to_server('mouseClick', params)

      nil
    end

    def dblclick(x, y, button: nil, delay: nil)
      click(x, y, button: button, clickCount: 2, delay: delay)
    end

    def wheel(deltaX, deltaY)
      params = {
        deltaX: deltaX,
        deltaY: deltaY,
      }
      @channel.send_message_to_server('mouseWheel', params)
      nil
    end
  end
end
