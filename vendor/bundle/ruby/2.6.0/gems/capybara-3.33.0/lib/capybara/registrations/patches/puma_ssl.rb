# frozen_string_literal: true

module Puma
  module MiniSSL
    class Socket
      def read_nonblock(size, *_)
        loop do
          output = engine_read_all
          return output if output

          data = @socket.read_nonblock(size, exception: false)
          raise IO::EAGAINWaitReadable if %i[wait_readable wait_writable].include? data
          return nil if data.nil?

          @engine.inject(data)
          output = engine_read_all

          return output if output

          while (neg_data = @engine.extract)
            @socket.write neg_data
          end
        end
      end
    end
  end
end
