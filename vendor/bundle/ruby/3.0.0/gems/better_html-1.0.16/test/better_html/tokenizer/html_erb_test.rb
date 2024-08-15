require 'test_helper'
require 'better_html/tokenizer/html_erb'

module BetterHtml
  module Tokenizer
    class HtmlErbTest < ActiveSupport::TestCase
      test "text" do
        scanner = HtmlErb.new(buffer("just some text"))
        assert_equal 1, scanner.tokens.size

        assert_attributes ({
          type: :text,
          loc: { begin_pos: 0, end_pos: 14, source: 'just some text' }
        }), scanner.tokens[0]
      end

      test "statement" do
        scanner = HtmlErb.new(buffer("<% statement %>"))
        assert_equal 3, scanner.tokens.size

        assert_attributes ({ type: :erb_begin, loc: { begin_pos: 0, end_pos: 2, source: '<%' } }), scanner.tokens[0]
        assert_attributes ({ type: :code, loc: { begin_pos: 2, end_pos: 13, source: ' statement ' } }), scanner.tokens[1]
        assert_attributes ({ type: :erb_end, loc: { begin_pos: 13, end_pos: 15, source: '%>' } }), scanner.tokens[2]
      end

      test "debug statement" do
        scanner = HtmlErb.new(buffer("<%# statement %>"))
        assert_equal 4, scanner.tokens.size

        assert_attributes ({ type: :erb_begin, loc: { begin_pos: 0, end_pos: 2, source: '<%' } }), scanner.tokens[0]
        assert_attributes ({ type: :indicator, loc: { begin_pos: 2, end_pos: 3, source: '#' } }), scanner.tokens[1]
        assert_attributes ({ type: :code, loc: { begin_pos: 3, end_pos: 14, source: ' statement ' } }), scanner.tokens[2]
        assert_attributes ({ type: :erb_end, loc: { begin_pos: 14, end_pos: 16, source: '%>' } }), scanner.tokens[3]
      end

      test "when multi byte characters are present in erb" do
        code = "<% ui_helper 'your store’s' %>"
        scanner = HtmlErb.new(buffer(code))
        assert_equal 3, scanner.tokens.size

        assert_attributes ({ type: :erb_begin, loc: { begin_pos: 0, end_pos: 2, source: '<%' } }), scanner.tokens[0]
        assert_attributes ({ type: :code, loc: { begin_pos: 2, end_pos: 28, source: " ui_helper 'your store’s' " } }), scanner.tokens[1]
        assert_attributes ({ type: :erb_end, loc: { begin_pos: 28, end_pos: 30, source: '%>' } }), scanner.tokens[2]
        assert_equal code.length, scanner.current_position
      end

      test "when multi byte characters are present in text" do
        code = "your store’s"
        scanner = HtmlErb.new(buffer(code))
        assert_equal 1, scanner.tokens.size

        assert_attributes ({ type: :text, loc: { begin_pos: 0, end_pos: 12, source: 'your store’s' } }), scanner.tokens[0]
        assert_equal code.length, scanner.current_position
      end

      test "when multi byte characters are present in html" do
        code = "<div title='your store’s'>foo</div>"
        scanner = HtmlErb.new(buffer(code))
        assert_equal 14, scanner.tokens.size

        assert_attributes ({ type: :tag_start, loc: { begin_pos: 0, end_pos: 1, source: '<' } }), scanner.tokens[0]
        assert_attributes ({ type: :tag_name, loc: { begin_pos: 1, end_pos: 4, source: "div" } }), scanner.tokens[1]
        assert_attributes ({ type: :whitespace, loc: { begin_pos: 4, end_pos: 5, source: " " } }), scanner.tokens[2]
        assert_attributes ({ type: :attribute_name, loc: { begin_pos: 5, end_pos: 10, source: "title" } }), scanner.tokens[3]
        assert_attributes ({ type: :equal, loc: { begin_pos: 10, end_pos: 11, source: "=" } }), scanner.tokens[4]
        assert_attributes ({ type: :attribute_quoted_value_start, loc: { begin_pos: 11, end_pos: 12, source: "'" } }), scanner.tokens[5]
        assert_attributes ({ type: :attribute_quoted_value, loc: { begin_pos: 12, end_pos: 24, source: "your store’s" } }), scanner.tokens[6]
        assert_attributes ({ type: :attribute_quoted_value_end, loc: { begin_pos: 24, end_pos: 25, source: "'" } }), scanner.tokens[7]
        assert_equal code.length, scanner.current_position
      end

      test "expression literal" do
        scanner = HtmlErb.new(buffer("<%= literal %>"))
        assert_equal 4, scanner.tokens.size

        assert_attributes ({ type: :erb_begin, loc: { begin_pos: 0, end_pos: 2, source: '<%' } }), scanner.tokens[0]
        assert_attributes ({ type: :indicator, loc: { begin_pos: 2, end_pos: 3, source: '=' } }), scanner.tokens[1]
        assert_attributes ({ type: :code, loc: { begin_pos: 3, end_pos: 12, source: ' literal ' } }), scanner.tokens[2]
        assert_attributes ({ type: :erb_end, loc: { begin_pos: 12, end_pos: 14, source: '%>' } }), scanner.tokens[3]
      end

      test "expression escaped" do
        scanner = HtmlErb.new(buffer("<%== escaped %>"))
        assert_equal 4, scanner.tokens.size

        assert_attributes ({ type: :erb_begin, loc: { begin_pos: 0, end_pos: 2, source: '<%' } }), scanner.tokens[0]
        assert_attributes ({ type: :indicator, loc: { begin_pos: 2, end_pos: 4, source: '==' } }), scanner.tokens[1]
        assert_attributes ({ type: :code, loc: { begin_pos: 4, end_pos: 13, source: ' escaped ' } }), scanner.tokens[2]
        assert_attributes ({ type: :erb_end, loc: { begin_pos: 13, end_pos: 15, source: '%>' } }), scanner.tokens[3]
      end

      test "line number for multi-line statements" do
        scanner = HtmlErb.new(buffer("before <% multi\nline %> after"))
        assert_equal 5, scanner.tokens.size

        assert_attributes ({ type: :text, loc: { line: 1, source: 'before ' } }), scanner.tokens[0]
        assert_attributes ({ type: :erb_begin, loc: { line: 1, source: '<%' } }), scanner.tokens[1]
        assert_attributes ({ type: :code, loc: { line: 1, start_line: 1, stop_line: 2, source: " multi\nline " } }), scanner.tokens[2]
        assert_attributes ({ type: :erb_end, loc: { line: 2, source: "%>" } }), scanner.tokens[3]
        assert_attributes ({ type: :text, loc: { line: 2, source: " after" } }), scanner.tokens[4]
      end

      test "multi-line statements with trim" do
        scanner = HtmlErb.new(buffer("before\n<% multi\nline -%>\nafter"))
        assert_equal 7, scanner.tokens.size

        assert_attributes ({ type: :text, loc: { line: 1, source: "before\n" } }), scanner.tokens[0]
        assert_attributes ({ type: :erb_begin, loc: { line: 2, source: '<%' } }), scanner.tokens[1]
        assert_attributes ({ type: :code, loc: { line: 2, source: " multi\nline " } }), scanner.tokens[2]
        assert_attributes ({ type: :trim, loc: { line: 3, source: "-" } }), scanner.tokens[3]
        assert_attributes ({ type: :erb_end, loc: { line: 3, source: "%>" } }), scanner.tokens[4]
        assert_attributes ({ type: :text, loc: { line: 3, source: "\n" } }), scanner.tokens[5]
        assert_attributes ({ type: :text, loc: { line: 4, source: "after" } }), scanner.tokens[6]
      end

      test "right trim with =%>" do
        scanner = HtmlErb.new(buffer("<% trim =%>"))
        assert_equal 4, scanner.tokens.size

        assert_attributes ({ type: :erb_begin, loc: { line: 1, source: '<%' } }), scanner.tokens[0]
        assert_attributes ({ type: :code, loc: { line: 1, source: " trim " } }), scanner.tokens[1]
        assert_attributes ({ type: :trim, loc: { line: 1, source: "=" } }), scanner.tokens[2]
        assert_attributes ({ type: :erb_end, loc: { line: 1, source: "%>" } }), scanner.tokens[3]
      end

      test "multi-line expression with trim" do
        scanner = HtmlErb.new(buffer("before\n<%= multi\nline -%>\nafter"))
        assert_equal 8, scanner.tokens.size

        assert_attributes ({ type: :text, loc: { line: 1, source: "before\n" } }), scanner.tokens[0]
        assert_attributes ({ type: :erb_begin, loc: { line: 2, source: '<%' } }), scanner.tokens[1]
        assert_attributes ({ type: :indicator, loc: { line: 2, source: '=' } }), scanner.tokens[2]
        assert_attributes ({ type: :code, loc: { line: 2, source: " multi\nline " } }), scanner.tokens[3]
        assert_attributes ({ type: :trim, loc: { line: 3, source: "-" } }), scanner.tokens[4]
        assert_attributes ({ type: :erb_end, loc: { line: 3, source: "%>" } }), scanner.tokens[5]
        assert_attributes ({ type: :text, loc: { line: 3, source: "\n" } }), scanner.tokens[6]
        assert_attributes ({ type: :text, loc: { line: 4, source: "after" } }), scanner.tokens[7]
      end

      test "line counts with comments" do
        scanner = HtmlErb.new(buffer("before\n<%# BO$$ Mode %>\nafter"))
        assert_equal 7, scanner.tokens.size

        assert_attributes ({ type: :text, loc: { line: 1, source: "before\n" } }), scanner.tokens[0]
        assert_attributes ({ type: :erb_begin, loc: { line: 2, source: '<%' } }), scanner.tokens[1]
        assert_attributes ({ type: :indicator, loc: { line: 2, source: '#' } }), scanner.tokens[2]
        assert_attributes ({ type: :code, loc: { line: 2, source: " BO$$ Mode " } }), scanner.tokens[3]
        assert_attributes ({ type: :erb_end, loc: { line: 2, source: "%>" } }), scanner.tokens[4]
        assert_attributes ({ type: :text, loc: { line: 2, source: "\n" } }), scanner.tokens[5]
        assert_attributes ({ type: :text, loc: { line: 3, source: "after" } }), scanner.tokens[6]
      end

      test "escaped opening ERB tag <%%" do
        scanner = HtmlErb.new(buffer("just some <%%= text %> no erb"))
        assert_equal 6, scanner.tokens.size

        assert_attributes ({ type: :text, loc: { line: 1, source: "just some " } }), scanner.tokens[0]
        assert_attributes ({ type: :erb_begin, loc: { line: 1, source: '<%' } }), scanner.tokens[1]
        assert_attributes ({ type: :indicator, loc: { line: 1, source: "%" } }), scanner.tokens[2]
        assert_attributes ({ type: :code, loc: { line: 1, source: "= text " } }), scanner.tokens[3]
        assert_attributes ({ type: :erb_end, loc: { line: 1, source: "%>" } }), scanner.tokens[4]
        assert_attributes ({ type: :text, loc: { line: 1, source: " no erb" } }), scanner.tokens[5]
      end

      private

      def assert_attributes(attributes, token)
        attributes.each do |key, value|
          if value.nil?
            assert_nil token.send(key)
          elsif value.is_a?(Hash)
            assert_attributes(value, token.send(key))
          else
            assert_equal value, token.send(key)
          end
        end
      end
    end
  end
end
