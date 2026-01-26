require 'open3'
require 'tempfile'
require 'json'

module Yosys2Digitaljs
  class Runner
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
        
        stdout, stderr, status = Open3.capture3('yosys', '-p', yosys_script, source_file.path)

        unless status.success?
          raise Error, "Yosys Compilation Failed:\n#{stdout}\n#{stderr}"
        end

        raw_json_str = File.read(json_file.path)
        
        if raw_json_str.strip.empty?
             raise Error, "Yosys produced empty output. Check syntax errors in stderr: #{stderr}"
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
