# frozen_string_literal: true

require 'json'
require 'open3'
require "stringio"

module Playwright
  # ref: https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_transport.py
  class Transport
    # @param playwright_cli_executable_path [String] path to playwright-cli.
    def initialize(playwright_cli_executable_path:)
      @driver_executable_path = playwright_cli_executable_path
      @debug = ENV['DEBUG'].to_s == 'true' || ENV['DEBUG'].to_s == '1'
      @mutex = Mutex.new
    end

    def on_message_received(&block)
      @on_message = block
    end

    def on_driver_closed(&block)
      @on_driver_closed = block
    end

    def on_driver_crashed(&block)
      @on_driver_crashed = block
    end

    class AlreadyDisconnectedError < StandardError ; end

    # @param message [Hash]
    def send_message(message)
      debug_send_message(message) if @debug
      msg = JSON.dump(message)
      @mutex.synchronize {
        @stdin.write([msg.bytes.length].pack('V')) # unsigned 32bit, little endian, real byte size instead of chars
        @stdin.write(msg) # write UTF-8 in binary mode as byte stream
      }
    rescue Errno::EPIPE, IOError
      raise AlreadyDisconnectedError.new('send_message failed')
    end

    # Terminate playwright-cli driver.
    def stop
      [@stdin, @stdout, @stderr].each { |io| io.close unless io.closed? }
      @thread&.join
    end

    # Start `playwright-cli run-driver`
    #
    # @note This method blocks until playwright-cli exited. Consider using Thread or Future.
    def async_run
      @stdin, @stdout, @stderr, @thread = run_driver_with_open3
      @stdin.binmode  # Ensure Strings are written 1:1 without encoding conversion, necessary for integer values

      Thread.new { handle_stdout }
      Thread.new { handle_stderr }
    end

    private

    def run_driver_with_open3
      Open3.popen3("#{@driver_executable_path} run-driver", { pgroup: true })
    rescue ArgumentError => err
      # Windows doesn't accept pgroup parameter.
      # ArgumentError: wrong exec option symbol: pgroup
      if err.message =~ /pgroup/
        Open3.popen3("#{@driver_executable_path} run-driver")
      else
        raise
      end
    end

    def handle_stdout(packet_size: 32_768)
      while chunk = @stdout.read(4)
        length = chunk.unpack1('V') # unsigned 32bit, little endian
        buffer = StringIO.new
        (length / packet_size).to_i.times do
          buffer << @stdout.read(packet_size)
        end
        buffer << @stdout.read(length % packet_size)
        buffer.rewind
        obj = JSON.parse(buffer.read)

        debug_recv_message(obj) if @debug
        @on_message&.call(obj)
      end
    rescue IOError
      # disconnected by remote.
      @on_driver_closed&.call
    end

    def handle_stderr
      while err = @stderr.read
        # sometimed driver crashes with the error below.
        # --------
        # undefined:1
        # �
        # ^

        # SyntaxError: Unexpected token � in JSON at position 0
        #     at JSON.parse (<anonymous>)
        #     at Transport.transport.onmessage (/home/runner/work/playwright-ruby-client/playwright-ruby-client/node_modules/playwright/lib/cli/driver.js:42:73)
        #     at Immediate.<anonymous> (/home/runner/work/playwright-ruby-client/playwright-ruby-client/node_modules/playwright/lib/protocol/transport.js:74:26)
        #     at processImmediate (internal/timers.js:461:21)
        if err.include?('undefined:1')
          @on_driver_crashed&.call
          break
        end
        $stderr.write(err)
      end
    rescue IOError
      # disconnected by remote.
      @on_driver_closed&.call
    end

    def debug_send_message(message)
      metadata = message.delete(:metadata)
      puts "\x1b[33mSEND>\x1b[0m#{shorten_double_quoted_string(message)}"
      message[:metadata] = metadata
    end

    def debug_recv_message(message)
      puts "\x1b[33mRECV>\x1b[0m#{shorten_double_quoted_string(message)}"
    end

    def shorten_double_quoted_string(message, maxlen: 512)
      message.to_s.gsub(/"([^"]+)"/) do |str|
        if $1.length > maxlen
          "\"#{$1[0...maxlen]}...\""
        else
          str
        end
      end
    end
  end
end
