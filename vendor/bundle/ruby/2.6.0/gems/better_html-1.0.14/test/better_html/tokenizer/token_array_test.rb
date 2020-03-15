require 'test_helper'
require 'better_html/tokenizer/token'
require 'better_html/tokenizer/location'
require 'better_html/tokenizer/token_array'

module BetterHtml
  module Tokenizer
    class TokenArrayTest < ActiveSupport::TestCase
      setup do
        @document = "<x>"
        @buffer = buffer(@document)
        @tokens = [
          Token.new(type: :lquote, loc: Location.new(@buffer, 0, 0)),
          Token.new(type: :name, loc: Location.new(@buffer, 1, 1)),
          Token.new(type: :rquote, loc: Location.new(@buffer, 2, 2)),
        ]
        @array = TokenArray.new(@tokens)
      end

      test "size" do
        assert_equal 3, @array.size
      end

      test "size for empty array" do
        @array = TokenArray.new([])
        assert_equal 0, @array.size
      end

      test "shift returns element from beginning of array" do
        assert_equal @tokens.first, @array.shift
      end

      test "shift decreases the size by 1" do
        assert_difference(-> { @array.size }, -1) do
          @array.shift
        end
      end

      test "after shift, current element is changed" do
        assert_equal @tokens.first, @array.current
        assert_equal @tokens.first, @array.shift
        assert_equal @tokens.second, @array.current
      end

      test "pop returns element from the end of array" do
        assert_equal @tokens.last, @array.pop
      end

      test "pop decreases the size by 1" do
        assert_difference(-> { @array.size }, -1) do
          @array.pop
        end
      end

      test "after pop, last element is changed" do
        assert_equal @tokens.last, @array.last
        assert_equal @tokens.last, @array.pop
        assert_equal @tokens.second, @array.last
      end

      test "current returns element from beginning of array" do
        assert_equal @tokens.first, @array.current
      end

      test "current does not change size" do
        assert_no_difference(-> { @array.size }) do
          @array.current
        end
      end

      test "last returns element from the end of array" do
        assert_equal @tokens.last, @array.last
      end

      test "last does not change size" do
        assert_no_difference(-> { @array.size }) do
          @array.last
        end
      end

      test "empty?" do
        refute_predicate @array, :empty?
        3.times { @array.shift }
        assert_predicate @array, :empty?
      end

      test "any?" do
        assert_predicate @array, :any?
        3.times { @array.shift }
        refute_predicate @array, :any?
      end

      test "current is nil when array is empty" do
        @array = TokenArray.new([])
        assert_nil @array.current
      end

      test "last is nil when array is empty" do
        @array = TokenArray.new([])
        assert_nil @array.last
      end

      test "shift raises for empty array" do
        @array = TokenArray.new([])
        e = assert_raises(RuntimeError) do
          @array.shift
        end
        assert_equal 'no tokens left to shift', e.message
      end

      test "pop raises for empty array" do
        @array = TokenArray.new([])
        e = assert_raises(RuntimeError) do
          @array.pop
        end
        assert_equal 'no tokens left to pop', e.message
      end

      test "trim takes elements from the beginning of array" do
        assert_difference(-> { @array.size }, -1) do
          @array.trim(:lquote)
        end

        assert_equal @tokens.second, @array.current
      end

      test "trim takes elements from the end of array" do
        assert_difference(-> { @array.size }, -1) do
          @array.trim(:rquote)
        end

        assert_equal @tokens.second, @array.last
      end

      test "trim does not change array when element types are not at front nor back of array" do
        assert_no_difference(-> { @array.size }) do
          @array.trim(:name)
        end

        assert_equal @tokens.first, @array.current
        assert_equal @tokens.last, @array.last
      end
    end
  end
end
