require 'open3'
require 'tempfile'
require 'json'
require 'timeout'

module Yosys2Digitaljs
  class Runner
    # Custom error for timeouts
    class TimeoutError < StandardError; end
    
    # 20 seconds timeout for Yosys compilation
    TIMEOUT_LIMIT = 20

    def self.compile(verilog_code)
      new.compile(verilog_code)
    end

    def compile(verilog_code)
      source_file = Tempfile.new(['input', '.sv'])
      source_file.write(verilog_code)
      source_file.close

      begin
        json_file = Tempfile.new(['output', '.json'])
        json_file.close
        
        yosys_script = "prep -auto-top; write_json #{json_file.path}"
        
        stdout_str = ""
        stderr_str = ""
        exit_status = nil

        pid = nil
        begin
          Timeout.timeout(TIMEOUT_LIMIT) do
            # Securely spawn process with pipe capturing
            Open3.popen3('yosys', '-p', yosys_script, source_file.path) do |_stdin, stdout, stderr, wait_thr|
              pid = wait_thr.pid
              
              # Capture output
              stdout_str = stdout.read
              stderr_str = stderr.read
              exit_status = wait_thr.value # Wait for process
            end
          end
        rescue Timeout::Error
          if pid
            Process.kill('TERM', pid) rescue Errno::ESRCH
            begin
              Process.wait(pid)
            rescue Errno::ECHILD, Errno::ESRCH
              # Process already reaped or gone
            end
          end
          # Force kill the process if timeout occurs
          raise TimeoutError, "Yosys compilation timed out after #{TIMEOUT_LIMIT} seconds."
        rescue Errno::ENOENT
          raise StandardError, "Yosys binary not found. Please ensure Yosys is installed and available in your PATH."
        end

        unless exit_status&.success?
          raise Error, "Yosys Compilation Failed:\n#{stdout_str}\n#{stderr_str}"
        end

        raw_json_str = File.read(json_file.path)
        
        if raw_json_str.strip.empty?
             raise Error, "Yosys produced empty output. Check syntax errors in stderr: #{stderr_str}"
        end
        
        yosys_json = JSON.parse(raw_json_str)

        converter = Converter.new(yosys_json)
        converter.convert

      ensure
        source_file.unlink
        json_file&.unlink
      end
    end
  end
end
