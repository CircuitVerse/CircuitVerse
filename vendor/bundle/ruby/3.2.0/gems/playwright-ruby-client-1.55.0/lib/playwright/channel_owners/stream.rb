require 'base64'

module Playwright
  define_channel_owner :Stream do
    def save_as(path)
      File.open(path, 'wb') do |f|
        read_with_block do |chunk|
          f.write(chunk)
        end
      end
    end

    def read_all(&block)
      out = StringIO.new
      read_with_block do |chunk|
        out.write(chunk)
      end
      out.string
    end

    private def read_with_block(&block)
      loop do
        binary = @channel.send_message_to_server('read', size: 1024 * 1024)
        break if !binary || binary.length == 0
        decoded_chunk = Base64.strict_decode64(binary)
        block.call(decoded_chunk)
      end
    end
  end
end
