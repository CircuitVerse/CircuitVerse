module Terrapin
  class CommandLine
    class MultiPipe
      def initialize
        @stdout_in, @stdout_out = IO.pipe
        @stderr_in, @stderr_out = IO.pipe
      end

      def pipe_options
        { out: @stdout_out, err: @stderr_out }
      end

      def output
        Output.new(@stdout_output, @stderr_output)
      end

      def read_and_then(&block)
        close_write
        read
        block.call
        close_read
      end

      private

      def close_write
        @stdout_out.close
        @stderr_out.close
      end

      def read
        read_streams(@stdout_in, @stderr_in)
      end

      def close_read
        begin
          @stdout_in.close
        rescue IOError
          # do nothing
        end

        begin
        @stderr_in.close
        rescue IOError
          # do nothing
        end
      end

      def read_streams(output, error)
        @stdout_output = String.new
        @stderr_output = String.new
        read_fds = [output, error]
        while !read_fds.empty?
          to_read, = IO.select(read_fds)
          if to_read.include?(output)
            @stdout_output << read_stream(output)
            read_fds.delete(output) if output.closed?
          end

          if to_read.include?(error)
            @stderr_output << read_stream(error)
            read_fds.delete(error) if error.closed?
          end
        end
      end

      def read_stream(io)
        result = String.new
        begin
          while partial_result = io.read_nonblock(8192)
            result << partial_result
          end
        rescue EOFError, Errno::EPIPE
          io.close
        rescue Errno::EINTR, Errno::EWOULDBLOCK, Errno::EAGAIN
          # do nothing
        end
        result
      end
    end
  end
end
