# frozen_string_literal: true

require "htmlbeautifier/parser"
require "htmlbeautifier/ruby_indenter"

module HtmlBeautifier
  class Builder
    DEFAULT_OPTIONS = {
      indent: "  ",
      initial_level: 0,
      stop_on_errors: false,
      keep_blank_lines: 0
    }.freeze

    def initialize(output, options = {})
      options = DEFAULT_OPTIONS.merge(options)
      @tab = options[:indent]
      @stop_on_errors = options[:stop_on_errors]
      @level = options[:initial_level]
      @keep_blank_lines = options[:keep_blank_lines]
      @new_line = false
      @empty = true
      @ie_cc_levels = []
      @output = output
      @embedded_indenter = RubyIndenter.new
    end

    private

    def error(text)
      return unless @stop_on_errors

      raise text
    end

    def indent
      @level += 1
    end

    def outdent
      error "Extraneous closing tag" if @level == 0
      @level = [@level - 1, 0].max
    end

    def emit(*strings)
      strings_join = strings.join("")
      @output << "\n" if @new_line && !@empty
      @output << (@tab * @level) if @new_line && !strings_join.strip.empty?
      @output << strings_join
      @new_line = false
      @empty = false
    end

    def new_line
      @new_line = true
    end

    def embed(opening, code, closing)
      lines = code.split(%r{\n}).map(&:strip)
      outdent if @embedded_indenter.outdent?(lines)
      emit opening, code, closing
      indent if @embedded_indenter.indent?(lines)
    end

    def foreign_block(opening, code, closing)
      emit opening
      emit_reindented_block_content code unless code.strip.empty?
      emit closing
    end

    def emit_reindented_block_content(code)
      lines = code.strip.split(%r{\n})
      indentation = foreign_block_indentation(code)

      indent
      new_line
      lines.each do |line|
        emit line.rstrip.sub(%r{^#{indentation}}, "")
        new_line
      end
      outdent
    end

    def foreign_block_indentation(code)
      code.split(%r{\n}).find { |ln| !ln.strip.empty? }[%r{^\s+}]
    end

    def preformatted_block(opening, content, closing)
      new_line
      emit opening, content, closing
      new_line
    end

    def standalone_element(elem)
      emit elem
      new_line if elem =~ %r{^<br[^\w]}
    end

    def close_element(elem)
      outdent
      emit elem
    end

    def close_block_element(elem)
      close_element elem
      new_line
    end

    def open_element(elem)
      emit elem
      indent
    end

    def open_block_element(elem)
      new_line
      open_element elem
    end

    def close_ie_cc(elem)
      if @ie_cc_levels.empty?
        error "Unclosed conditional comment"
      else
        @level = @ie_cc_levels.pop
      end
      emit elem
    end

    def open_ie_cc(elem)
      emit elem
      @ie_cc_levels.push @level
      indent
    end

    def new_lines(*content)
      blank_lines = content.first.scan(%r{\n}).count - 1
      blank_lines = [blank_lines, @keep_blank_lines].min
      @output << ("\n" * blank_lines)
      new_line
    end

    alias_method :text, :emit
  end
end
