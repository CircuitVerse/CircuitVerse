require_relative "three_valued_logic"
require_relative "yosys2digitaljs/converter"
require_relative "yosys2digitaljs/runner"
require_relative "yosys2digitaljs/memory_processor"
require_relative "yosys2digitaljs/net_grouper"
require_relative "yosys2digitaljs/verilog_validator"

module Yosys2Digitaljs
  class Error < StandardError; end
  # Raised when pre-validation catches syntax errors before invoking Yosys
  class SyntaxError < Error; end
end
