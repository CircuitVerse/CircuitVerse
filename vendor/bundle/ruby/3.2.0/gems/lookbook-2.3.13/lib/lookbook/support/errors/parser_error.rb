module Lookbook
  class ParserError < Error
    def initialize(msg = nil, scope: "parser", **kwargs)
      super
    end
  end
end
