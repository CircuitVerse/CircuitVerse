# frozen_string_literal: true

module Arel # :nodoc: all
  module Nodes
    class Extract < Arel::Nodes::Unary
      attr_accessor :field

      def initialize(expr, field)
        super(expr)
        @field = field
      end

      def hash
        super ^ @field.hash
      end

      def eql?(other)
        super &&
          self.field == other.field
      end
      alias :== :eql?
    end
  end
end
