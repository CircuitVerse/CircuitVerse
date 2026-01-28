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
      # Pre-validate Verilog syntax before invoking Yosys
      VerilogValidator.validate!(verilog_code)

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
              
              # Capture output concurrently to avoid deadlock
              stdout_thread = Thread.new { stdout.read }
              stderr_thread = Thread.new { stderr.read }
              
              stdout_str = stdout_thread.value
              stderr_str = stderr_thread.value
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
          clean_error = extract_yosys_errors(stdout_str, stderr_str)
          raise Error, clean_error
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

    private

    # Extract clean error messages from Yosys output
    # Filters out verbose copyright/license text and keeps only ERROR and Warning lines
    def extract_yosys_errors(stdout_str, stderr_str)
      combined = "#{stdout_str}\n#{stderr_str}"
      
      # Extract lines that contain actual errors or warnings
      error_lines = combined.lines.select do |line|
        line =~ /\bERROR\b/i || line =~ /\bWarning\b/i || line =~ /syntax error/i
      end.map(&:strip).reject(&:empty?)

      if error_lines.any?
        # Clean up each error line: remove temp file paths, make more readable
        cleaned = error_lines.map do |line|
          # Replace temp file paths like /tmp/input20260128-501-md88fg.sv:9: with "Line number"
          line.gsub(%r{/tmp/[^:]+\.sv?:(\d+):}, 'Line \1:')
              .gsub(/\bERROR:\s*/, '')  # Remove redundant ERROR: prefix
              .strip
        end.uniq
        
        # Format the final message
        "Syntax error: #{cleaned.join('; ')}"
      else
        # Fallback if no ERROR lines found
        "Yosys compilation failed. Check your Verilog syntax."
      end
    end
  end
end
