# frozen_string_literal: true

module Solargraph
  class Source
    class Chain
      class Hash < Literal
        # @param type [String]
        # @param node [Parser::AST::Node]
        # @param splatted [Boolean]
        def initialize type, node, splatted = false
          super(type, node)
          @splatted = splatted
        end

        # @sg-ignore Fix "Not enough arguments to Module#protected"
        protected def equality_fields
          super + [@splatted]
        end

        def word
          @word ||= "<#{@type}>"
        end

        def resolve api_map, name_pin, locals
          [Pin::ProxyType.anonymous(@complex_type, source: :chain)]
        end

        def splatted?
          @splatted
        end
      end
    end
  end
end
