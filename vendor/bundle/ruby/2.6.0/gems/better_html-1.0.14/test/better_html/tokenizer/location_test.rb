require 'test_helper'
require 'better_html/tokenizer/location'

module BetterHtml
  module Tokenizer
    class LocationTest < ActiveSupport::TestCase
      test "location start out of bounds" do
        e = assert_raises(ArgumentError) do
          Location.new(buffer("foo"), 5, 6)
        end
        assert_equal "begin_pos location 5 is out of range for document of size 3", e.message
      end

      test "location stop out of bounds" do
        e = assert_raises(ArgumentError) do
          Location.new(buffer("foo"), 2, 6)
        end
        assert_equal "end_pos location 6 is out of range for document of size 3", e.message
      end

      test "location stop < start" do
        e = assert_raises(ArgumentError) do
          Location.new(buffer("aaaaaa"), 5, 2)
        end
        assert_equal "Parser::Source::Range: end_pos must not be less than begin_pos", e.message
      end

      test "location stop == start" do
        loc = Location.new(buffer("aaaaaa"), 5, 5)
        assert_equal "", loc.source
        assert_equal 0, loc.size
      end

      test "end_pos is stop+1" do
        loc = Location.new(buffer("aaaaaa"), 5, 5)
        assert_equal 5, loc.end_pos
      end

      test "range is exclusive of last char" do
        loc = Location.new(buffer("aaaaaa"), 5, 5)
        assert_equal 5...5, loc.range
      end

      test "location calulates start and stop line and column" do
        loc = Location.new(buffer("foo\nbar\nbaz"), 5, 10)

        assert_equal "ar\nba", loc.source
        assert_equal 2, loc.start_line
        assert_equal 1, loc.start_column
        assert_equal 3, loc.stop_line
        assert_equal 2, loc.stop_column
      end

      test "line_source_with_underline" do
        loc = Location.new(buffer("ui_helper(foo)"), 10, 13)

        assert_equal "foo", loc.source
        assert_equal <<~EOL.strip, loc.line_source_with_underline
          ui_helper(foo)
                    ^^^
        EOL
      end

      test "line_source_with_underline removes empty spaces" do
        loc = Location.new(buffer("   \t   ui_helper(foo)"), 17, 20)

        assert_equal "foo", loc.source
        assert_equal <<~EOL.strip, loc.line_source_with_underline
          ui_helper(foo)
                    ^^^
        EOL
      end
    end
  end
end
