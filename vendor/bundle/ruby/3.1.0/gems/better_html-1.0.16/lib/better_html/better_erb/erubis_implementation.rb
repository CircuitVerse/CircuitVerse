require 'action_view'
require_relative 'runtime_checks'

class BetterHtml::BetterErb
  class ErubisImplementation < ActionView::Template::Handlers::Erubis
    include RuntimeChecks

    def add_text(src, text)
      return if text.empty?

      if text == "\n"
        @parser.parse("\n")
        @newline_pending += 1
      else
        src << "@output_buffer.safe_append='"
        src << "\n" * @newline_pending if @newline_pending > 0
        src << escape_text(text)
        src << "'.freeze;"

        @parser.parse(text) do |*args|
          check_token(*args)
        end

        @newline_pending = 0
      end
    end

    def add_expr_literal(src, code)
      add_expr_auto_escaped(src, code, true)
    end

    def add_expr_escaped(src, code)
      add_expr_auto_escaped(src, code, false)
    end

    def add_stmt(src, code)
      flush_newline_if_pending(src)

      block_check(src, "<%#{code}%>")
      @parser.append_placeholder(code)
      super
    end
  end
end
