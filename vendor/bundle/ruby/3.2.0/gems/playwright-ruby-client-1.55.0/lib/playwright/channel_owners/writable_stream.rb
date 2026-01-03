require 'base64'

module Playwright
  define_channel_owner :WritableStream do
    # @param readable [File|IO]
    def write(readable, bufsize = 1048576)
      while buf = readable.read(bufsize)
        binary = Base64.strict_encode64(buf)
        @channel.send_message_to_server('write', binary: binary)
      end
      @channel.send_message_to_server('close')
    end
  end
end
