require 'test_helper'
require 'better_html/tokenizer/html_lodash'

module BetterHtml
  module Tokenizer
    class HtmlLodashTest < ActiveSupport::TestCase
      test "matches text" do
        scanner = HtmlLodash.new(buffer("just some text"))
        assert_equal 1, scanner.tokens.size

        assert_attributes ({ type: :text, loc: { begin_pos: 0, end_pos: 14, source: "just some text" } }), scanner.tokens[0]
      end

      test "matches strings to be escaped" do
        scanner = HtmlLodash.new(buffer("[%= foo %]"))
        assert_equal 4, scanner.tokens.size

        assert_attributes ({ type: :lodash_begin, loc: { begin_pos: 0, end_pos: 2, source: "[%" } }), scanner.tokens[0]
        assert_attributes ({ type: :indicator, loc: { begin_pos: 2, end_pos: 3, source: "=" } }), scanner.tokens[1]
        assert_attributes ({ type: :code, loc: { begin_pos: 3, end_pos: 8, source: " foo " } }), scanner.tokens[2]
        assert_attributes ({ type: :lodash_end, loc: { begin_pos: 8, end_pos: 10, source: "%]" } }), scanner.tokens[3]
      end

      test "matches interpolate" do
        scanner = HtmlLodash.new(buffer("[%! foo %]"))
        assert_equal 4, scanner.tokens.size

        assert_attributes ({ type: :lodash_begin, loc: { begin_pos: 0, end_pos: 2, source: "[%" } }), scanner.tokens[0]
        assert_attributes ({ type: :indicator, loc: { begin_pos: 2, end_pos: 3, source: "!" } }), scanner.tokens[1]
        assert_attributes ({ type: :code, loc: { begin_pos: 3, end_pos: 8, source: " foo " } }), scanner.tokens[2]
        assert_attributes ({ type: :lodash_end, loc: { begin_pos: 8, end_pos: 10, source: "%]" } }), scanner.tokens[3]
      end

      test "matches statement" do
        scanner = HtmlLodash.new(buffer("[% foo %]"))
        assert_equal 3, scanner.tokens.size

        assert_attributes ({ type: :lodash_begin, loc: { begin_pos: 0, end_pos: 2, source: "[%" } }), scanner.tokens[0]
        assert_attributes ({ type: :code, loc: { begin_pos: 2, end_pos: 7, source: " foo " } }), scanner.tokens[1]
        assert_attributes ({ type: :lodash_end, loc: { begin_pos: 7, end_pos: 9, source: "%]" } }), scanner.tokens[2]
      end

      test "matches text before and after" do
        scanner = HtmlLodash.new(buffer("before\n[%= foo %]\nafter"))
        assert_equal 6, scanner.tokens.size

        assert_attributes ({ type: :text, loc: { begin_pos: 0, end_pos: 7, source: "before\n" } }), scanner.tokens[0]
        assert_attributes ({ type: :lodash_begin, loc: { begin_pos: 7, end_pos: 9, source: "[%" } }), scanner.tokens[1]
        assert_attributes ({ type: :indicator, loc: { begin_pos: 9, end_pos: 10, source: "=" } }), scanner.tokens[2]
        assert_attributes ({ type: :code, loc: { begin_pos: 10, end_pos: 15, source: " foo " } }), scanner.tokens[3]
        assert_attributes ({ type: :lodash_end, loc: { begin_pos: 15, end_pos: 17, source: "%]" } }), scanner.tokens[4]
        assert_attributes ({ type: :text, loc: { begin_pos: 17, end_pos: 23, source: "\nafter" } }), scanner.tokens[5]
      end

      test "matches multiple" do
        scanner = HtmlLodash.new(buffer("[% if() { %][%= foo %][% } %]"))
        assert_equal 10, scanner.tokens.size

        assert_attributes ({ type: :lodash_begin, loc: { source: "[%" } }), scanner.tokens[0]
        assert_attributes ({ type: :code, loc: { source: " if() { " } }), scanner.tokens[1]
        assert_attributes ({ type: :lodash_end, loc: { source: "%]" } }), scanner.tokens[2]

        assert_attributes ({ type: :lodash_begin, loc: { source: "[%" } }), scanner.tokens[3]
        assert_attributes ({ type: :indicator, loc: { source: "=" } }), scanner.tokens[4]
        assert_attributes ({ type: :code, loc: { source: " foo " } }), scanner.tokens[5]
        assert_attributes ({ type: :lodash_end, loc: { source: "%]" } }), scanner.tokens[6]

        assert_attributes ({ type: :lodash_begin, loc: { source: "[%" } }), scanner.tokens[7]
        assert_attributes ({ type: :code, loc: { source: " } " } }), scanner.tokens[8]
        assert_attributes ({ type: :lodash_end, loc: { source: "%]" } }), scanner.tokens[9]
      end

      test "parses out html correctly" do
        scanner = HtmlLodash.new(buffer('<div class="[%= foo %]">'))
        assert_equal 12, scanner.tokens.size
        assert_equal [:tag_start, :tag_name, :whitespace, :attribute_name,
          :equal, :attribute_quoted_value_start,
          :lodash_begin, :indicator, :code, :lodash_end,
          :attribute_quoted_value_end, :tag_end], scanner.tokens.map(&:type)
        assert_equal ["<", "div", " ", "class", "=", "\"", "[%", "=", " foo ", "%]", "\"", ">"], scanner.tokens.map(&:loc).map(&:source)
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
