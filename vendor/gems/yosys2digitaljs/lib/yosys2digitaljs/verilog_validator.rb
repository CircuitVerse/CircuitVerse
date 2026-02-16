# frozen_string_literal: true

module Yosys2Digitaljs
  # Lightweight Verilog pre-validator to catch obvious syntax errors
  # before invoking Yosys. This provides cleaner error messages.
  # does NOT perform semantic analysis,, that is left to Yosys.
  class VerilogValidator
    def self.validate!(code)
      new(code).validate!
    end

    def initialize(code)
      @code = code.to_s
      @errors = []
    end

    def validate!
      return if @code.strip.empty?

      # Strip comments before analysis
      clean_code = strip_comments(@code)

      check_module_structure(clean_code)
      check_balanced_brackets(clean_code)
      check_balanced_begin_end(clean_code)

      raise Yosys2Digitaljs::SyntaxError, @errors.join('; ') if @errors.any?
    end

    private

    # Check for module/endmodule pairs
    def check_module_structure(clean_code)
      module_count = clean_code.scan(/\bmodule\b/).count
      endmodule_count = clean_code.scan(/\bendmodule\b/).count

      if module_count.zero?
        @errors << "No 'module' declaration found"
      elsif module_count != endmodule_count
        @errors << "Mismatched module/endmodule: found #{module_count} 'module' and #{endmodule_count} 'endmodule'"
      end
    end

    # Check for balanced parentheses, brackets, and braces
    def check_balanced_brackets(clean_code)
      pairs = { '(' => ')', '[' => ']', '{' => '}' }
      stack = []

      clean_code.each_char.with_index do |char, idx|
        if pairs.key?(char)
          stack.push([char, idx])
        elsif pairs.value?(char)
          expected_open = pairs.key(char)
          if stack.empty? || stack.last[0] != expected_open
            line_num = @code[0..idx].count("\n") + 1
            @errors << "Unmatched '#{char}' at line #{line_num}"
            return
          end
          stack.pop
        end
      end

      stack.each do |open_char, idx|
        line_num = @code[0..idx].count("\n") + 1
        @errors << "Unmatched '#{open_char}' at line #{line_num}"
      end
    end

    # Check for balanced begin/end blocks
    # Note: \bend\b only matches standalone 'end', not compound keywords like endmodule
    def check_balanced_begin_end(clean_code)
      begin_count = clean_code.scan(/\bbegin\b/).count
      end_count = clean_code.scan(/\bend\b/).count

      return unless begin_count != end_count

      @errors << "Mismatched begin/end: found #{begin_count} 'begin' and #{end_count} 'end'"
    end

    # Strip single-line (//) and multi-line (/* */) comments
    def strip_comments(code)
      result = []
      in_multiline_comment = false
      i = 0

      while i < code.length
        if in_multiline_comment
          if code[i, 2] == '*/'
            in_multiline_comment = false
            i += 2
          else
            i += 1
          end
        elsif code[i, 2] == '//'
          i += 1 while i < code.length && code[i] != "\n"
        elsif code[i, 2] == '/*'
          in_multiline_comment = true
          i += 2
        else
          result << code[i]
          i += 1
        end
      end

      result.join
    end
  end
end
