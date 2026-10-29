# frozen_string_literal: true

require "rails_helper"
require "puma"
require "puma/client"
require "puma/server"
require "socket"

RSpec.describe "PumaClientDisconnectPatch" do
  it "prepends PumaClientDisconnectPatch into Puma::Client" do
    expect(Puma::Client <= PumaClientDisconnectPatch).to be true
  end

  describe "#eagerly_finish" do
    let(:socket_pair) { Socket.pair(:UNIX, :STREAM, 0) }
    let(:server_socket) { socket_pair[0] }
    let(:client_socket) { socket_pair[1] }
    let(:client) { Puma::Client.new(server_socket, {}) }

    after do
      server_socket.close unless server_socket.closed?
      client_socket.close unless client_socket.closed?
    end

    it "translates Errno::EBADF from wait_readable into Puma::ConnectionError" do
      allow(server_socket.to_io).to receive(:wait_readable).with(0).and_raise(Errno::EBADF, "Bad file descriptor")

      expect { client.eagerly_finish }.to raise_error(
        Puma::ConnectionError,
        "Connection error detected during eagerly_finish"
      )
    end

    it "translates IOError from wait_readable into Puma::ConnectionError" do
      allow(server_socket.to_io).to receive(:wait_readable).with(0).and_raise(IOError, "closed stream")

      expect { client.eagerly_finish }.to raise_error(
        Puma::ConnectionError,
        "Connection error detected during eagerly_finish"
      )
    end

    it "does not rescue unrelated exceptions" do
      allow(server_socket.to_io).to receive(:wait_readable).with(0).and_raise(RuntimeError, "unexpected error")

      expect { client.eagerly_finish }.to raise_error(RuntimeError, "unexpected error")
    end

    it "returns true immediately if the client is already ready" do
      client.instance_variable_set(:@ready, true)
      expect(client.eagerly_finish).to be true
    end

    it "returns false when no data is available on the socket" do
      allow(server_socket.to_io).to receive(:wait_readable).with(0).and_return(nil)
      expect(client.eagerly_finish).to be false
    end
  end

  describe "#finish" do
    let(:socket_pair) { Socket.pair(:UNIX, :STREAM, 0) }
    let(:server_socket) { socket_pair[0] }
    let(:client_socket) { socket_pair[1] }
    let(:client) { Puma::Client.new(server_socket, {}) }

    after do
      server_socket.close unless server_socket.closed?
      client_socket.close unless client_socket.closed?
    end

    it "translates Errno::EBADF from wait_readable into Puma::ConnectionError" do
      allow(client).to receive(:try_to_finish).and_return(false)
      allow(server_socket.to_io).to receive(:wait_readable).with(1).and_raise(Errno::EBADF, "Bad file descriptor")

      expect { client.finish(1) }.to raise_error(
        Puma::ConnectionError,
        "Connection error detected during finish"
      )
    end

    it "translates IOError from wait_readable into Puma::ConnectionError" do
      allow(client).to receive(:try_to_finish).and_return(false)
      allow(server_socket.to_io).to receive(:wait_readable).with(1).and_raise(IOError, "closed stream")

      expect { client.finish(1) }.to raise_error(
        Puma::ConnectionError,
        "Connection error detected during finish"
      )
    end

    it "does not rescue unrelated exceptions" do
      allow(client).to receive(:try_to_finish).and_return(false)
      allow(server_socket.to_io).to receive(:wait_readable).with(1).and_raise(RuntimeError, "unexpected error")

      expect { client.finish(1) }.to raise_error(RuntimeError, "unexpected error")
    end

    it "returns immediately if the client is already ready" do
      client.instance_variable_set(:@ready, true)
      expect(client.finish(1)).to be_nil
    end
  end

  describe "Puma::Server client error handling integration" do
    def read_with_deadline(io, timeout: 5.0)
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
      buf = +""
      loop do
        remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
        raise "Socket read timed out after #{timeout}s" if remaining <= 0
        raise "Socket read timed out after #{timeout}s" unless io.wait_readable(remaining)

        chunk = io.read_nonblock(1024, exception: false)
        case chunk
        when :wait_readable
          next
        when nil
          return buf.empty? ? nil : buf
        else
          buf << chunk
          return buf if block_given? && yield(buf)
        end
      end
    rescue Errno::ECONNRESET, Errno::ECONNABORTED, Errno::EPIPE, EOFError
      buf.empty? ? nil : buf
    end

    it "safely closes the client without invoking lowlevel_error_handler when eagerly_finish raises EBADF" do
      lowlevel_errors = []
      conf = Puma::Configuration.new do |cfg|
        cfg.app { [200, { "content-type" => "text/plain" }, ["OK"]] }
        cfg.bind "tcp://127.0.0.1:0"
        cfg.lowlevel_error_handler do |err, _env, _status|
          lowlevel_errors << err
          [500, {}, ["Internal Error"]]
        end
      end
      conf.clamp

      launcher = nil
      server_thread = nil
      s1 = nil
      s2 = nil
      orig_init = nil

      begin
        launcher = Puma::Launcher.new(conf, log_writer: Puma::LogWriter.null)
        server_thread = Thread.new { launcher.run }

        startup_deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 5.0
        until launcher.connected_ports&.any?
          raise "Puma startup timed out" if Process.clock_gettime(Process::CLOCK_MONOTONIC) > startup_deadline

          sleep 0.01
        end
        port = launcher.connected_ports.first

        injected_queue = Thread::Queue.new

        # Create s1 socket and bind to an ephemeral local port BEFORE connecting
        # so target_port is known with 100% precision before connection establishment
        s1 = Socket.new(:INET, :STREAM)
        s1.bind(Addrinfo.tcp("127.0.0.1", 0))
        target_port = s1.local_address.ip_port

        # Patch Puma::Client#initialize targeting ONLY connections from target_port
        orig_init = Puma::Client.instance_method(:initialize)
        Puma::Client.define_method(:initialize) do |io, env = nil|
          orig_init.bind_call(self, io, env)

          return unless io.respond_to?(:peeraddr) && io.peeraddr[1] == target_port

          to_io = @to_io
          to_io.define_singleton_method(:wait_readable) do |_timeout = 0|
            injected_queue.push(:injected)
            raise Errno::EBADF, "Bad file descriptor"
          end
        end

        # Connect s1 now that hook is installed with its exact known port
        s1.connect(Addrinfo.tcp("127.0.0.1", port))
        s1.write("GET / HTTP/1.1\r\nHost: example.com\r\n\r\n")

        # Deterministically wait for injection to execute during eagerly_finish (max 5s timeout)
        expect(injected_queue.pop(timeout: 5)).to eq(:injected)

        # Server safely closes s1; verify EOF or reset within bounded timeout
        res = read_with_deadline(s1)
        expect(res).to be_nil

        # Subsequent request on s2 should succeed normally, proving worker threads survived
        s2 = TCPSocket.new("127.0.0.1", port)
        s2.write("GET / HTTP/1.1\r\nHost: example.com\r\n\r\n")

        response = read_with_deadline(s2) { |data| data.include?("\r\n") }
        expect(response).to include("200 OK")

        # Verify lowlevel_error_handler was not invoked
        expect(lowlevel_errors).to be_empty
      ensure
        Puma::Client.define_method(:initialize, orig_init) if orig_init
        begin
          s1&.close
        rescue StandardError
          nil
        end
        begin
          s2&.close
        rescue StandardError
          nil
        end
        begin
          launcher&.stop
        rescue StandardError
          nil
        end
        if server_thread && !server_thread.join(5.0)
          server_thread.kill
          server_thread.join(1.0)
        end
      end
    end
  end
end
