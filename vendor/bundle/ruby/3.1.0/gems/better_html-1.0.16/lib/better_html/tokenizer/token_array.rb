module BetterHtml
  module Tokenizer
    class TokenArray
      def initialize(list)
        @list = list
        @current = 0
        @last = @list.size
      end

      def shift
        raise RuntimeError, 'no tokens left to shift' if empty?
        item = @list[@current]
        @current += 1
        item
      end

      def pop
        raise RuntimeError, 'no tokens left to pop' if empty?
        item = @list[@last - 1]
        @last -= 1
        item
      end

      def trim(type)
        while current&.type == type
          shift
        end
        while last&.type == type
          pop
        end
      end

      def empty?
        size <= 0
      end

      def any?
        !empty?
      end

      def current
        @list[@current] unless empty?
      end

      def last
        @list[@last - 1] unless empty?
      end

      def size
        @last - @current
      end
    end
  end
end
