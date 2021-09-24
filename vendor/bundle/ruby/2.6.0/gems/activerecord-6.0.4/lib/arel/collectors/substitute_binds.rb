# frozen_string_literal: true

module Arel # :nodoc: all
  module Collectors
    class SubstituteBinds
      def initialize(quoter, delegate_collector)
        @quoter = quoter
        @delegate = delegate_collector
      end

      def <<(str)
        delegate << str
        self
      end

      def add_bind(bind)
        self << quoter.quote(bind)
      end

      def value
        delegate.value
      end

      private
        attr_reader :quoter, :delegate
    end
  end
end
