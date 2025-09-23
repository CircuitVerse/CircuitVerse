module Playwright
  define_api_implementation :KeyboardImpl do
    def initialize(channel)
      @channel = channel
    end

    def down(key)
      @channel.send_message_to_server('keyboardDown', key: key)
      nil
    end

    def up(key)
      @channel.send_message_to_server('keyboardUp', key: key)
    end

    def insert_text(text)
      @channel.send_message_to_server('keyboardInsertText', text: text)
    end

    def type(text, delay: nil)
      params = {
        text: text,
        delay: delay,
      }.compact
      @channel.send_message_to_server('keyboardType', params)
    end

    def press(key, delay: nil)
      params = {
        key: key,
        delay: delay,
      }.compact
      @channel.send_message_to_server('keyboardPress', params)
    end
  end
end
